DROP VIEW IF EXISTS staging.sales_unique;   -- depends on staging.sales; recreated at the end
DROP TABLE IF EXISTS staging.sales;
CREATE TABLE staging.sales AS
WITH typed AS (
    SELECT
        NULLIF(TRIM(invoice_id), '') AS invoice_id,   -- supposed to be unique but is not. in some years one invoice has many lines
        CASE WHEN ordered_on ~ '^\d{4}-\d{2}-\d{2}' THEN LEFT(ordered_on, 10)::date END AS sale_date,
        NULLIF(TRIM(store_no), '') AS store_number,
        NULLIF(TRIM(category_name), '') AS category_raw,
        NULLIF(TRIM(vendor_name), '') AS vendor_raw,
        NULLIF(TRIM(item_no), '') AS item_number,
        NULLIF(TRIM(im_desc), '') AS item_description,
        CASE WHEN bottle_volume_ml ~ '^\d+(\.\d+)?$' THEN bottle_volume_ml::numeric END AS bottle_ml,
        CASE WHEN sales_bottles ~ '^-?\d+$' THEN sales_bottles::int END AS bottles_sold,
        CASE WHEN regexp_replace(sales_dollars, '[$,]', '', 'g') ~ '^-?\d+(\.\d+)?$'
             THEN regexp_replace(sales_dollars, '[$,]', '', 'g')::numeric END AS sale_dollars,
        -- Reported liters, or bottle size x bottles when liters is 0/missing (0 on many 2025-26 rows)
        CASE WHEN sales_liters ~ '^-?\d+(\.\d+)?$' AND sales_liters::numeric <> 0
                 THEN sales_liters::numeric
             WHEN bottle_volume_ml ~ '^\d+(\.\d+)?$' AND sales_bottles ~ '^-?\d+$'
                 THEN bottle_volume_ml::numeric * sales_bottles::int / 1000.0
        END AS liters,
        NOT COALESCE(sales_liters ~ '^-?\d+(\.\d+)?$' AND sales_liters::numeric <> 0, false) AS liters_derived,
        ROW_NUMBER() OVER () AS sale_row_id,   -- surrogate key (regenerated on every rebuild)
        -- copy_no > 1 = a later copy of a row identical in all 23 raw columns
        ROW_NUMBER() OVER (PARTITION BY invoice_id, ordered_on, store_no, store_name, store_address,
            store_city, store_zip_code, county_fips_code, county_name, category_code, category_name,
            vendor_number, vendor_name, item_no, im_desc, pack, bottle_volume_ml, state_bottle_cost,
            state_bottle_retail, sales_bottles, sales_dollars, sales_liters, sales_gallons) AS copy_no
    FROM raw.liquor_sales
),
flagged AS (
    SELECT *, (copy_no > 1) AS flag_duplicate_row
    FROM typed
)
SELECT
    sale_row_id, invoice_id, sale_date,
    EXTRACT(YEAR FROM sale_date)::int AS sale_year,
    date_trunc('month', sale_date)::date AS sale_month,
    store_number, category_raw, vendor_raw, item_number, item_description,
    bottle_ml, bottles_sold, sale_dollars, liters, liters_derived,
    (sale_date IS NULL) AS flag_bad_date,
    (bottles_sold IS NULL OR bottles_sold = 0) AS flag_bad_qty,
    (liters IS NULL OR liters = 0) AS flag_bad_volume,
    (bottles_sold < 0 OR liters < 0) AS flag_return,   -- returns/credits: kept in totals, they net out
    -- mini multi-packs (sleeves, dispensers, buckets) recorded with the single-mini volume:
    -- over $100/L for a bottle of 200 ml or less is a pack, so liters are understated
    (bottle_ml <= 200 AND bottles_sold > 0 AND sale_dollars / NULLIF(liters, 0) > 100) AS flag_multipack,
    flag_duplicate_row
FROM flagged;   -- every row is kept; extra copies are flagged, not deleted
-- (no WHERE clause: the marts filter on flag_duplicate_row instead)

CREATE INDEX ON staging.sales (sale_date);
CREATE INDEX ON staging.sales (store_number);
ALTER TABLE staging.sales ADD PRIMARY KEY (sale_row_id);
ANALYZE staging.sales;

-- What the marts read: every row except the extra copies of exact duplicates
CREATE OR REPLACE VIEW staging.sales_unique AS
SELECT * FROM staging.sales WHERE NOT flag_duplicate_row;