DROP TABLE IF EXISTS staging.stores;
CREATE TABLE staging.stores AS
WITH base AS (
    SELECT
        NULLIF(TRIM(store_no), '') AS store_number,
        UPPER(regexp_replace(TRIM(store_name), '\s+', ' ', 'g')) AS store_name,
        NULLIF(UPPER(TRIM(store_address)), '') AS address,
        NULLIF(UPPER(TRIM(store_city)), '') AS city,
        NULLIF(LEFT(regexp_replace(store_zip_code, '\D', '', 'g'), 5), '') AS zip5,
        NULLIF(TRIM(county_fips_code), '') AS county_fips_raw,
        NULLIF(UPPER(TRIM(county_name)), '') AS county,
        CASE WHEN ordered_on ~ '^\d{4}-\d{2}-\d{2}' THEN LEFT(ordered_on, 10)::date END AS sale_date
    FROM raw.liquor_sales
),
combos AS (   -- collapse to distinct store details first. much cheaper than sorting every row
    SELECT store_number, store_name, address, city, zip5, county_fips_raw, county,
           MAX(sale_date) AS last_seen
    FROM base
    WHERE store_number IS NOT NULL
    GROUP BY 1, 2, 3, 4, 5, 6, 7
)
SELECT DISTINCT ON (store_number)
    store_number, store_name, address, city, zip5, county_fips_raw, county, last_seen
FROM combos
ORDER BY store_number, (address IS NULL), last_seen DESC NULLS LAST;   -- prefer a row that has an address, then the most recent

-- 5-digit county FIPS (Iowa = 19)
ALTER TABLE staging.stores ADD COLUMN county_fips TEXT;
UPDATE staging.stores SET county_fips = CASE
    WHEN county_fips_raw ~ '^\d{5}$' THEN county_fips_raw
    WHEN county_fips_raw ~ '^\d{1,3}$' THEN '19' || LPAD(county_fips_raw, 3, '0') END;

-- use each store's most common county (not the one on its latest row), so a few stray rows can't move a whole store
UPDATE staging.stores s
SET county = COALESCE(x.county, s.county),
    county_fips = COALESCE(x.county_fips, s.county_fips)
FROM (SELECT NULLIF(TRIM(store_no), '') AS store_number,
             mode() WITHIN GROUP (ORDER BY NULLIF(UPPER(TRIM(county_name)), '')) AS county,
             mode() WITHIN GROUP (ORDER BY CASE
                 WHEN TRIM(county_fips_code) ~ '^\d{5}$' THEN TRIM(county_fips_code)
                 WHEN TRIM(county_fips_code) ~ '^\d{1,3}$' THEN '19' || LPAD(TRIM(county_fips_code), 3, '0') END) AS county_fips
      FROM raw.liquor_sales
      GROUP BY 1) x
WHERE s.store_number = x.store_number;   -- check (should return zero rows): SELECT county_fips, COUNT(DISTINCT county) FROM staging.stores GROUP BY 1 HAVING COUNT(DISTINCT county) > 1;

-- The Data Hub files have no latitude/longitude. These empty columns keep the later queries
-- running; a store map is optional (geocode the addresses later if you want one).
ALTER TABLE staging.stores ADD COLUMN lat numeric, ADD COLUMN lon numeric;

ALTER TABLE staging.stores ADD PRIMARY KEY (store_number);

-- Manual ZIP corrections (verified against store addresses; see DQ-18)
UPDATE staging.stores SET zip5 = '52722' WHERE store_number = '2687';  -- Bettendorf, transposed (57222 -> 52722, Bettendorf, IA)
UPDATE staging.stores SET zip5 = '52761' WHERE store_number = '5091';  -- Muscatine, transposed (from 52671)
UPDATE staging.stores SET zip5 = '52057' WHERE store_number = '5054';  -- Manchester, typo
UPDATE staging.stores SET zip5 = '52403' WHERE store_number = '5142';  -- 52303 bad, 52403 good
UPDATE staging.stores SET zip5 = '52732' WHERE store_number IN ('4204', '4864');  -- Clinton PO-box ZIP
-- 5142 (Cedar Rapids, 52303): set after checking its address