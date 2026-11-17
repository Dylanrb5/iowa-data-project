SELECT string_agg(
  format('COUNT(*) FILTER (WHERE NULLIF(TRIM(%I), '''') IS NULL) AS %I',
         column_name, column_name || '_missing'), E',\n')
FROM information_schema.columns
WHERE table_schema = 'raw' AND table_name = 'liquor_sales';
-- returns the below query for finding missing values

SELECT 
COUNT(*) FILTER (WHERE NULLIF(TRIM(invoice_id), '') IS NULL) AS invoice_id_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(ordered_on), '') IS NULL) AS ordered_on_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(store_no), '') IS NULL) AS store_no_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(store_name), '') IS NULL) AS store_name_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(store_address), '') IS NULL) AS store_address_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(store_city), '') IS NULL) AS store_city_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(store_zip_code), '') IS NULL) AS store_zip_code_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(county_fips_code), '') IS NULL) AS county_fips_code_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(county_name), '') IS NULL) AS county_name_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(category_code), '') IS NULL) AS category_code_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(category_name), '') IS NULL) AS category_name_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(vendor_number), '') IS NULL) AS vendor_number_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(vendor_name), '') IS NULL) AS vendor_name_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(item_no), '') IS NULL) AS item_no_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(im_desc), '') IS NULL) AS im_desc_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(pack), '') IS NULL) AS pack_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(bottle_volume_ml), '') IS NULL) AS bottle_volume_ml_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(state_bottle_cost), '') IS NULL) AS state_bottle_cost_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(state_bottle_retail), '') IS NULL) AS state_bottle_retail_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(sales_bottles), '') IS NULL) AS sales_bottles_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(sales_dollars), '') IS NULL) AS sales_dollars_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(sales_liters), '') IS NULL) AS sales_liters_missing,
COUNT(*) FILTER (WHERE NULLIF(TRIM(sales_gallons), '') IS NULL) AS sales_gallons_missing
from raw.liquor_sales;

SELECT COUNT(*) FROM raw.liquor_sales;   
-- 26,500,494

-- do the location fields go missing on the same rows?
SELECT COUNT(*) FILTER (WHERE NULLIF(TRIM(store_address), '') IS NULL) AS no_address,
       COUNT(*) FILTER (WHERE NULLIF(TRIM(county_fips_code), '') IS NULL) AS no_fips,
       COUNT(*) FILTER (WHERE NULLIF(TRIM(store_address), '') IS NULL
                          AND NULLIF(TRIM(county_fips_code), '') IS NULL) AS both
FROM raw.liquor_sales;
--|no_address|no_fips|both|
--|----------|-------|----|
--|58251|58252|58250|


-- which years are affected
SELECT LEFT(ordered_on, 4) AS yr,
       COUNT(*) FILTER (WHERE NULLIF(TRIM(county_fips_code), '') IS NULL) AS no_county,
       COUNT(*) FILTER (WHERE NULLIF(TRIM(state_bottle_cost), '') IS NULL) AS no_cost,
       COUNT(*) AS n
FROM raw.liquor_sales GROUP BY yr ORDER BY yr;
--|yr|no_county|no_cost|n|
--|--|---------|-------|-|
--|2017|43476|2291276|2291276|
--|2018|1695|2355558|2355558|
--|2019|4764|2380345|2380345|
--|2020|135|3147745|3147745|
--|2021|196|3098706|3098706|
--|2022|1844|2958969|2958969|
--|2023|1177|2639557|2639557|
--|2024|422|2590975|2590975|
--|2025|1961|1213529|3007599|
--|2026|2582|0|2029764|

-- which stores account for the missing county
SELECT store_no, store_name, COUNT(*) AS rows_missing
FROM raw.liquor_sales WHERE NULLIF(TRIM(county_fips_code), '') IS NULL
GROUP BY 1, 2 ORDER BY 3 DESC LIMIT 20;
--|store_no|store_name|rows_missing|
--|--------|----------|------------|
--|2543|HY-VEE FOOD STORE #1 / OTTUMWA|7497|
--|5176|SMOKIN' JOE'S #15 TOBACCO & LIQUOR O|4365|
--|2591|HY-VEE WINE AND SPIRITS / ATLANTIC|4200|
--|2556|HY-VEE WINE AND SPIRITS / ESTHERVILLE|3800|
--|3420|SAM'S CLUB 6344 / WINDSOR HEIGHTS|3495|
--|4152|FOOD LAND SUPER MARKETS / MISSOURI VALEY|3470|
--|5142|SMOKIN' JOE'S #13 TOBACCO & LIQUOR O|3160|
--|4000|FOODLAND SUPER MARKETS / WOODBINE|2475|
--|010206|HAWKEYE SMOKE SHOP / FAIRFIELD|2474|
--|5167|NEW STAR LIQUOR & TOBACCO  / FT DODG|1381|
--|4447|QUIK TRIP #567 / URBANDALE|1172|
--|4829|CENTRAL CITY 2|1108|
--|3805|WASHINGTON STREET MINI MART|1047|
--|3822|THE SECRET CELLAR|1020|
--|4640|MART STOP #1 / DAVENPORT|935|
--|010039|LIQUOR LOVERS / ANKENY|935|
--|5230|POINT LIQUOR & TOBACCO|915|
--|5091|KUM & GO #436 / MUSCATINE|835|
--|010183|CROWN LIQUOR & SMOKE / IOWA CITY|696|
--|5243|NEW STAR / LAFAYETTE / WATERLOO|661|

-- confirming that store has non-missing location in other rows
SELECT store_name, county_fips_code, county_name, store_no, LEFT(ordered_on, 4) AS yr, COUNT(*)
FROM raw.liquor_sales 
WHERE store_name = 'HY-VEE FOOD STORE #1 / OTTUMWA'
AND NULLIF(TRIM(county_fips_code), '') IS NOT NULL
GROUP BY 1, 2, 3, 4, 5;
--|store_name|county_fips_code|county_name|count|
--|HY-VEE FOOD STORE #1 / OTTUMWA|19179|WAPELLO|32468|

SELECT store_name, county_fips_code, county_name, store_no, LEFT(ordered_on, 4) AS yr, COUNT(*)
FROM raw.liquor_sales 
WHERE store_name = 'HY-VEE FOOD STORE #1 / OTTUMWA'
AND NULLIF(TRIM(county_fips_code), '') IS NULL
GROUP BY 1, 2, 3, 4, 5;

-- rows whose date is missing or doesn't start YYYY-MM-DD
SELECT COUNT(*) FROM raw.liquor_sales
WHERE ordered_on IS NULL OR ordered_on !~ '^\d{4}-\d{2}-\d{2}';

-- total rows and num different categories per year
SELECT LEFT(ordered_on, 4) AS yr, COUNT(*) AS n, COUNT(DISTINCT category_name) AS categories
FROM raw.liquor_sales GROUP BY yr ORDER BY yr;

-- presence year range for each category, and total count
SELECT category_name, MIN(LEFT(ordered_on, 4)) AS first_yr, MAX(LEFT(ordered_on, 4)) AS last_yr, COUNT(*)
FROM raw.liquor_sales GROUP BY category_name ORDER BY 1 DESC;
--FROM raw.liquor_sales GROUP BY category_name ORDER BY COUNT(*) DESC;

-- find on which month the name changed
SELECT category_name, LEFT(ordered_on, 7) AS ym, COUNT(*) AS n
FROM raw.liquor_sales
WHERE category_name IN ('IMPORTED CORDIALS & LIQUEURS', 'IMPORTED CORDIALS & LIQUEUR')
  AND LEFT(ordered_on, 4) = '2025'
GROUP BY 1, 2 ORDER BY 2, 1;

-- same category code, different names
SELECT category_code, COUNT(DISTINCT category_name) AS names, array_agg(DISTINCT category_name) AS name_list
FROM raw.liquor_sales
GROUP BY category_code
HAVING COUNT(DISTINCT category_name) > 1
ORDER BY names DESC;

-- some stores with more than one name
SELECT store_no, COUNT(DISTINCT store_name) AS names, array_agg(DISTINCT store_name) AS name_list
FROM raw.liquor_sales GROUP BY store_no HAVING COUNT(DISTINCT store_name) > 1
ORDER BY names DESC 
LIMIT 50;
-- counts:
SELECT COUNT(*) AS stores_with_multiple_names,
       (SELECT COUNT(DISTINCT store_no) FROM raw.liquor_sales) AS total_stores
FROM (SELECT store_no FROM raw.liquor_sales
      GROUP BY store_no HAVING COUNT(DISTINCT store_name) > 1) t;
-- for each store_no, total different names, addresses, and cities:
SELECT store_no,
       COUNT(DISTINCT store_name) AS names,
       COUNT(DISTINCT UPPER(TRIM(store_address))) AS addresses,
       COUNT(DISTINCT UPPER(TRIM(store_city))) AS cities,
       COUNT(*) AS n_rows
FROM raw.liquor_sales
GROUP BY store_no
HAVING COUNT(DISTINCT store_name) > 1
ORDER BY cities DESC, addresses DESC, n_rows DESC;
-- track history of specific store id:
SELECT LEFT(ordered_on, 4) AS yr, store_name, store_address, store_city, county_name, COUNT(*) AS n
FROM raw.liquor_sales
WHERE store_no = '5405'
GROUP BY 1, 2, 3, 4, 5 ORDER BY 1, 2;
-- does any store id show up in 2+ cities in same month? (none):
WITH overlap AS (
    SELECT store_no, LEFT(ordered_on, 7) AS ym
    FROM raw.liquor_sales
    WHERE NULLIF(TRIM(store_city), '') IS NOT NULL
    GROUP BY 1, 2
    HAVING COUNT(DISTINCT UPPER(TRIM(store_city))) > 1
)
SELECT store_no, COUNT(*) AS months_with_2plus_cities, MIN(ym) AS first_ym, MAX(ym) AS last_ym
FROM overlap GROUP BY 1 ORDER BY months_with_2plus_cities DESC;
-- find same store id, different county
SELECT store_no,
       COUNT(DISTINCT county_fips_code) AS counties,
       array_agg(DISTINCT county_name) AS county_names,
       COUNT(*) AS n_rows,
       MIN(LEFT(ordered_on, 4)) AS first_yr, MAX(LEFT(ordered_on, 4)) AS last_yr
FROM raw.liquor_sales
WHERE NULLIF(TRIM(county_fips_code), '') IS NOT NULL
GROUP BY store_no
HAVING COUNT(DISTINCT county_fips_code) > 1
ORDER BY n_rows DESC;
--|store_no|counties|county_names|n_rows|first_yr|last_yr|
--|3461|2|{ADAIR,GUTHRIE}|20477|2017|2026|
--|2656|2|{ADAMS,CLAYTON}|19831|2017|2026|
--|4320|2|{BOONE,DALLAS}|16673|2017|2026|
--|4067|2|{WAPELLO,WASHINGTON}|12625|2017|2026|
SELECT UPPER(TRIM(store_address)) AS address, UPPER(TRIM(store_city)) AS city,
       COUNT(DISTINCT county_fips_code) AS counties,
       array_agg(DISTINCT county_name) AS county_names,
       COUNT(*) AS n_rows
FROM raw.liquor_sales
WHERE NULLIF(TRIM(store_address), '') IS NOT NULL
  AND NULLIF(TRIM(county_fips_code), '') IS NOT NULL
GROUP BY 1, 2
HAVING COUNT(DISTINCT county_fips_code) > 1
ORDER BY n_rows DESC;
-- show count of possible rebrands vs possible variants due to typos 
--|stores_with_multiple_names|likely_rebrands|name_variants_only|
--|320|256|64|:
WITH spans AS (
    SELECT
        NULLIF(TRIM(store_no), '') AS store_number,
        TRIM(regexp_replace(
                regexp_replace(UPPER(TRIM(store_name)), '#\s*\d+', '', 'g'),
                '[^A-Z0-9]+', ' ', 'g')) AS name_norm,          -- drops store #s, punctuation, spacing
        MIN(CASE WHEN ordered_on ~ '^\d{4}-\d{2}-\d{2}' THEN LEFT(ordered_on, 10)::date END) AS first_seen,
        MAX(CASE WHEN ordered_on ~ '^\d{4}-\d{2}-\d{2}' THEN LEFT(ordered_on, 10)::date END) AS last_seen
    FROM raw.liquor_sales
    WHERE NULLIF(TRIM(store_no), '') IS NOT NULL
    GROUP BY 1, 2
),
multi AS (   -- stores with more than one cleaned-up name
    SELECT store_number FROM spans GROUP BY 1 HAVING COUNT(*) > 1
),
rebrands AS (   -- an older name that ended before a newer one began
    SELECT DISTINCT a.store_number
    FROM spans a
    JOIN spans b ON a.store_number = b.store_number
                AND a.last_seen < b.first_seen
)
SELECT
    (SELECT COUNT(*) FROM multi)                               AS stores_with_multiple_names,
    (SELECT COUNT(*) FROM rebrands)                            AS likely_rebrands,
    (SELECT COUNT(*) FROM multi) - (SELECT COUNT(*) FROM rebrands) AS name_variants_only;
-- show likely store rebrands:
WITH spans AS (
    SELECT
        NULLIF(TRIM(store_no), '') AS store_number,
        TRIM(regexp_replace(
                regexp_replace(UPPER(TRIM(store_name)), '#\s*\d+', '', 'g'),
                '[^A-Z0-9]+', ' ', 'g')) AS name_norm,          -- drops store #s, punctuation, spacing
        MIN(CASE WHEN ordered_on ~ '^\d{4}-\d{2}-\d{2}' THEN LEFT(ordered_on, 10)::date END) AS first_seen,
        MAX(CASE WHEN ordered_on ~ '^\d{4}-\d{2}-\d{2}' THEN LEFT(ordered_on, 10)::date END) AS last_seen
    FROM raw.liquor_sales
    WHERE NULLIF(TRIM(store_no), '') IS NOT NULL
    GROUP BY 1, 2
)
SELECT a.store_number,
       a.name_norm AS old_name, a.first_seen AS old_from, a.last_seen AS old_to,
       b.name_norm AS new_name, b.first_seen AS new_from
FROM spans a
JOIN spans b ON a.store_number = b.store_number
            AND a.last_seen < b.first_seen
ORDER BY a.store_number, a.first_seen;

-- non-numeric quantities
SELECT COUNT(*) FILTER (WHERE sales_bottles !~ '^-?\d+$') AS bad_bottles,
       COUNT(*) FILTER (WHERE sales_liters !~ '^-?\d+(\.\d+)?$') AS bad_liters
FROM raw.liquor_sales;

-- is invoice_id unique and never empty?
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT invoice_id) AS distinct_ids,
       COUNT(*) FILTER (WHERE NULLIF(TRIM(invoice_id), '') IS NULL) AS missing_ids
FROM raw.liquor_sales;

-- county FIPS format: code lengths with examples (Iowa codes should be 19xxx)
SELECT LENGTH(county_fips_code) AS len, COUNT(*), MIN(county_fips_code), MAX(county_fips_code)
FROM raw.liquor_sales GROUP BY 1 ORDER BY 1;

-- find non-iowa codes
SELECT s.store_number, s.store_name, s.city, s.zip5, s.county, s.county_fips,
          ROUND(SUM(x.liters)) AS liters
FROM staging.stores s
LEFT JOIN staging.sales_unique x USING (store_number)
WHERE s.county_fips IS NULL OR s.county_fips NOT LIKE '19%' OR s.zip5 !~ '^5[0-2]'
GROUP BY 1,2,3,4,5,6 ORDER BY liters DESC NULLS LAST;
-- colorado store is the only one that doesn't match in census join
SELECT s.county AS in_sales, a.county AS in_census
FROM (SELECT DISTINCT county FROM staging.stores WHERE county IS NOT NULL) s
FULL JOIN (SELECT DISTINCT county FROM staging.acs_county) a USING (county)
WHERE s.county IS NULL OR a.county IS NULL;

SELECT
    -- sanity checks on the full table
    (SELECT COUNT(*) FROM raw.liquor_sales) - (SELECT COUNT(*) FROM staging.sales) AS rows_lost,          -- should be 0
    (SELECT COUNT(*) FROM staging.sales WHERE flag_duplicate_row)                  AS duplicate_copies,   -- should be 1,920,778
    -- flags on the rows the marts read
    COUNT(*)                                                    AS rows_used,
    COUNT(*) FILTER (WHERE flag_bad_date)                       AS bad_dates,
    COUNT(*) FILTER (WHERE flag_bad_qty)                        AS bad_qty,
    COUNT(*) FILTER (WHERE flag_bad_volume)                     AS bad_volume,
    COUNT(*) FILTER (WHERE flag_return)                         AS returns,
    COUNT(*) FILTER (WHERE liters_derived)                      AS liters_derived,
    ROUND(100.0 * COUNT(*) FILTER (WHERE flag_bad_qty)    / COUNT(*), 3) AS bad_qty_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE flag_bad_volume) / COUNT(*), 3) AS bad_volume_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE flag_return)     / COUNT(*), 3) AS returns_pct,
    ROUND(100.0 * COUNT(*) FILTER (WHERE liters_derived)  / COUNT(*), 3) AS liters_derived_pct
FROM staging.sales_unique;

