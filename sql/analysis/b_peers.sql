DROP TABLE IF EXISTS marts.store_peers;
CREATE TABLE marts.store_peers AS
WITH base AS (
    SELECT y.*,
           CASE WHEN store_type = 'big box' AND store_name ~ 'SAM''?S CLUB|COSTCO' THEN 'warehouse club'
           		WHEN store_type = 'grocery' AND store_name ~ 'DOLLAR FRESH' THEN 'Hy-Vee Dollar Fresh'
                WHEN store_type = 'grocery' AND store_name ~ 'HY-?VEE'  THEN 'Hy-Vee grocery'
				WHEN store_type = 'grocery' AND store_name ~ 'FAREWAY' THEN 'Fareway'
                WHEN store_type = 'grocery' THEN 'independent grocery'
                
                ELSE store_type END AS peer_type,
           -- town size from the store's ZIP area, not the county: small towns in metro counties
           -- shouldn't be compared with city stores
           CASE WHEN zcta_population < 5000 THEN 'small town'
                WHEN urban_rural = 'metro' THEN 'metro'
                ELSE 'non-metro town' END AS area_class,
           (SELECT MIN(f.sale_year) FROM marts.store_year f WHERE f.store_number = y.store_number) AS first_year
    FROM marts.store_year y
    WHERE sale_year = 2025 AND zcta_income IS NOT NULL AND active_months >= 10
      AND NOT supplier_profile   -- bar-supplier stores aren't comparable to shopper stores
      -- types with no meaningful peer group: catch-all, distilleries/wineries, bars/hotels, wholesalers
      AND store_type NOT IN ('other', 'producer', 'casino/hotel/bar', 'wholesale')
),
s AS (
    SELECT *, NTILE(3) OVER (PARTITION BY peer_type, area_class ORDER BY zcta_income) AS income_tercile
    FROM base
),
peers AS (
    SELECT peer_type, area_class, income_tercile,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY liters)  AS peer_median,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY dollars) AS peer_median_dollars,
           COUNT(*) AS peer_n
    FROM s GROUP BY 1, 2, 3
)
SELECT s.store_number, s.store_name, s.store_type, s.peer_type, s.area_class, s.urban_rural, s.income_tercile,
       s.county, s.lat, s.lon, s.first_year, s.liters, s.dollars, s.price_per_liter, s.multipack_dollar_share,
       p.peer_median, p.peer_median_dollars, p.peer_n,
       s.liters  / p.peer_median         AS ratio_to_peers,
       s.dollars / p.peer_median_dollars AS ratio_dollars,
       (s.first_year >= 2024) AS new_store,   -- opened recently: still building a customer base
       -- under-buying only if low on BOTH measures: liters alone penalize mini-heavy stores
       -- (multipack liters are understated), dollars alone penalize cheap-product stores.
       -- Stores must have sold for all of 2024 too, so new entrants aren't flagged.
       (s.liters / p.peer_median < 0.5 AND s.dollars / p.peer_median_dollars < 0.5
        AND s.first_year <= 2023 AND p.peer_n >= 10) AS flag_under
FROM s JOIN peers p USING (peer_type, area_class, income_tercile);

-- Flagged under-buyers
SELECT * FROM marts.store_peers WHERE flag_under ORDER BY ratio_dollars LIMIT 25;

-- New entrants that would otherwise look like under-buyers (report separately)
SELECT store_name, county, peer_type, first_year, ROUND(ratio_dollars::numeric, 2) AS ratio_dollars
FROM marts.store_peers
WHERE new_store AND ratio_dollars < 0.5
ORDER BY ratio_dollars;

-- Peer group sizes: groups under 10 stores can't flag anyone
SELECT peer_type, area_class, income_tercile, peer_n, ROUND(peer_median_dollars) AS median_dollars
FROM marts.store_peers
GROUP BY 1, 2, 3, 4, 5
ORDER BY 1, 2, 3;

-- 2023 stores ramping up late?
--SELECT store_number, store_name, sale_year, ROUND(dollars) AS dollars, active_months
--FROM marts.store_year
--WHERE store_number IN ('010202', '010307', '010217', '010224', '6216', '010167')
--  AND sale_year >= 2023
--ORDER BY store_number, sale_year;

--SELECT dollars/liters AS ppl, * FROM marts.store_year sy
--WHERE sale_year = 2025
--ORDER BY ppl DESC;

--SELECT * FROM staging.sales s
--WHERE store_number = '2717' AND sale_year = 2025
--ORDER BY bottle_ml DESC;


-- check opening date
--SELECT s.store_number, st.store_name, MIN(sale_date) AS first_sale
--FROM staging.sales_unique s
--LEFT JOIN staging.stores st ON st.store_number = s.store_number
--WHERE s.store_number IN ('010082', '010449', '010451', '010452')
--GROUP BY 1, 2;
--SELECT * FROM staging.stores s ;

@set sn = '4130'
--SELECT * FROM staging.stores s WHERE s.store_number = :sn;

-- 1. who is it? Name history, address, type, flags, active period
SELECT st.store_number, st.store_name, st.address, st.city, st.zip5, st.county,
       st.store_type, st.urban_rural, st.supplier_profile,
       MIN(s.sale_date) AS first_sale, MAX(s.sale_date) AS last_sale,
       (SELECT STRING_AGG(DISTINCT UPPER(TRIM(store_name)), ' | ')
        FROM raw.liquor_sales WHERE TRIM(store_no) = :sn) AS all_names
FROM staging.stores st
LEFT JOIN staging.sales_unique s USING (store_number)
WHERE st.store_number = :sn
GROUP BY 1,2,3,4,5,6,7,8,9;

-- 2. yearly trend: new, shrinking, or always small?
SELECT sale_year, ROUND(liters) AS liters, active_months
FROM marts.store_year
WHERE store_number = :sn
ORDER BY sale_year;

-- 3. ordering pattern in 2024-2025: how often and how much it buys
SELECT sale_month,
       COUNT(DISTINCT sale_date)    AS order_days,
       COUNT(DISTINCT item_number)  AS distinct_items,
       ROUND(SUM(liters))           AS liters
FROM staging.sales_unique
WHERE store_number = :sn AND sale_date >= '2024-01-01'
GROUP BY 1 ORDER BY 1;

-- 4. category mix vs peers (from b2_category_gaps)
SELECT family, ROUND(family_dollars) AS dollars, family_share, peer_share,
       ROUND(gap_dollars) AS gap_dollars, flag_mix_gap
FROM marts.store_category_gaps
WHERE store_number = :sn
ORDER BY gap_dollars DESC;

-- 5. local competition: other stores in the same ZIP, and when they opened
SELECT st.store_number, st.store_name, st.store_type,
       MIN(sy.sale_year) AS first_year, MAX(sy.sale_year) AS last_year,
       ROUND(SUM(sy.liters) FILTER (WHERE sy.sale_year = 2025)) AS liters_2025
FROM staging.stores st
JOIN marts.store_year sy USING (store_number)
WHERE st.zip5 = (SELECT zip5 FROM staging.stores WHERE store_number = :sn)
GROUP BY 1, 2, 3
ORDER BY liters_2025 DESC NULLS LAST;
