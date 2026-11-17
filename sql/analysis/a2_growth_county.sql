DROP TABLE IF EXISTS marts.growth_opportunities;
CREATE TABLE marts.growth_opportunities AS
WITH p AS (
    SELECT county, family,
        MAX(liters_retail_per_adult) FILTER (WHERE sale_year = 2019) AS lpa_2019,
        MAX(liters_retail_per_adult) FILTER (WHERE sale_year = 2025) AS lpa_2025,
        MAX(liters_retail)           FILTER (WHERE sale_year = 2025) AS liters_2025
    FROM marts.county_category_year
    WHERE sale_year IN (2019, 2025)
    GROUP BY 1, 2
)
SELECT *,
        ROUND(POWER(lpa_2025 / lpa_2019, 1.0 / 6) - 1, 4)              AS cagr,
        ROUND((lpa_2025 - lpa_2019) * liters_2025 / lpa_2025, 1)       AS added_liters_vs_2019_rate,
        RANK() OVER (PARTITION BY family ORDER BY POWER(lpa_2025 / lpa_2019, 1.0 / 6) DESC) AS rank_in_family
FROM p
WHERE lpa_2019 > 0 AND liters_2025 >= 1000;

SELECT family, COUNT(*) AS counties,
        ROUND(100 * MIN(cagr), 1) AS min_pct,
        ROUND(100 * PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cagr)::numeric, 1) AS median_pct,
        ROUND(100 * MAX(cagr), 1) AS max_pct
FROM marts.growth_opportunities
GROUP BY family ORDER BY median_pct DESC;

-- highest growth, top 5 counties per liquor family
SELECT family, rank_in_family, county,
        ROUND(lpa_2019, 2) AS lpa_2019, ROUND(lpa_2025, 2) AS lpa_2025,
        ROUND(100 * cagr, 1) AS cagr_pct,
        ROUND(liters_2025) AS liters_2025
FROM marts.growth_opportunities
WHERE rank_in_family <= 5
ORDER BY family, rank_in_family;

-- volume
SELECT county, family,
        ROUND(100 * cagr, 1) AS cagr_pct,
        ROUND(added_liters_vs_2019_rate) AS added_liters,
        ROUND(liters_2025) AS liters_2025
FROM marts.growth_opportunities
WHERE cagr > 0
ORDER BY added_liters_vs_2019_rate DESC
LIMIT 15;

SELECT county,
        COUNT(*) FILTER (WHERE rank_in_family <= 10) AS top10_families,
        ROUND(100 * AVG(cagr), 1) AS avg_cagr_pct
FROM marts.growth_opportunities
GROUP BY county
HAVING COUNT(*) FILTER (WHERE rank_in_family <= 10) >= 3
ORDER BY top10_families DESC, avg_cagr_pct DESC;

SELECT store_number, store_name, store_type,
        ROUND(SUM(liters) FILTER (WHERE sale_year = 2019)) AS liters_2019,
        ROUND(SUM(liters) FILTER (WHERE sale_year = 2025)) AS liters_2025
FROM marts.store_year
WHERE county = 'CLINTON'
GROUP BY 1, 2, 3
ORDER BY COALESCE(SUM(liters) FILTER (WHERE sale_year = 2025), 0)
       - COALESCE(SUM(liters) FILTER (WHERE sale_year = 2019), 0) DESC;

WITH both_years AS (
    SELECT store_number
    FROM marts.store_year
    WHERE sale_year IN (2019, 2025)
    GROUP BY 1
    HAVING COUNT(DISTINCT sale_year) = 2
)
SELECT county,
       ROUND(SUM(liters) FILTER (WHERE sale_year = 2019)) AS same_store_2019,
       ROUND(SUM(liters) FILTER (WHERE sale_year = 2025)) AS same_store_2025,
       ROUND(100 * (POWER(SUM(liters) FILTER (WHERE sale_year = 2025)
                        / SUM(liters) FILTER (WHERE sale_year = 2019), 1.0 / 6) - 1), 1) AS same_store_cagr_pct
FROM marts.store_year
WHERE store_number IN (SELECT store_number FROM both_years)
GROUP BY county
ORDER BY same_store_cagr_pct DESC;

-- 1. every DeWitt store: address and active dates
SELECT st.store_number, st.store_name, st.address, st.zip5, st.store_type,
       MIN(s.sale_date) AS first_sale, MAX(s.sale_date) AS last_sale,
       ROUND(SUM(s.liters)) AS total_liters
FROM staging.stores st
JOIN staging.sales_unique s USING (store_number)
WHERE st.city IN ('DEWITT', 'DE WITT')
GROUP BY 1, 2, 3, 4, 5
ORDER BY first_sale;

-- 2. monthly liters for the two stores, side by side
SELECT sale_month,
       ROUND(SUM(liters) FILTER (WHERE store_number = '5298')) AS travel_mart,
       ROUND(SUM(liters) FILTER (WHERE store_number = '5916')) AS another_round
FROM staging.sales_unique
WHERE store_number IN ('5298', '5916')
  AND sale_date >= '2019-01-01'
GROUP BY 1
ORDER BY 1;


SELECT CASE WHEN store_number = '5916' THEN 'Another Round' ELSE 'Other liquor stores' END AS grp,
       ROUND(SUM(bottle_ml * bottles_sold) / NULLIF(SUM(bottles_sold), 0)) AS avg_bottle_ml,
       ROUND(AVG(bottles_sold), 1) AS avg_bottles_per_line,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml >= 1750) / SUM(bottles_sold), 1) AS pct_bottles_1750ml_plus
FROM staging.sales_unique s
JOIN staging.stores st USING (store_number)
WHERE st.store_type = 'liquor store' AND s.sale_year = 2025 AND NOT s.flag_return
GROUP BY 1;

-- bottle size sales distribution, small, 750ml, 1L, >=1.75L
WITH top_stores AS (
    SELECT store_number FROM marts.store_year
    WHERE sale_year = 2025 AND store_type = 'liquor store'
    ORDER BY liters DESC LIMIT 10
)
SELECT st.store_name,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml < 750)   / SUM(bottles_sold), 1) AS pct_small,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml = 750)   / SUM(bottles_sold), 1) AS pct_750,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml = 1000)  / SUM(bottles_sold), 1) AS pct_1000,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml >= 1750) / SUM(bottles_sold), 1) AS pct_1750_plus
FROM staging.sales_unique s
JOIN staging.stores st USING (store_number)
WHERE s.store_number IN (SELECT store_number FROM top_stores)
  AND s.sale_year = 2025 AND NOT s.flag_return
GROUP BY st.store_name
ORDER BY pct_1000 DESC;


--retail vs bar supplier queries


SELECT st.store_number, st.store_name, st.county,
       ROUND(SUM(s.liters)) AS liters_2025,
       ROUND(100.0 * SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml = 1000) / SUM(s.bottles_sold), 1) AS pct_1000,
       ROUND(100.0 * SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml < 750)  / SUM(s.bottles_sold), 1) AS pct_small
FROM staging.sales_unique s
JOIN staging.stores st USING (store_number)
WHERE s.sale_year = 2025 AND NOT s.flag_return
GROUP BY 1, 2, 3
HAVING SUM(s.liters) >= 20000
   AND SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml = 1000) >= 0.5 * SUM(s.bottles_sold)
   AND SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml < 750)  <  0.03 * SUM(s.bottles_sold)
ORDER BY liters_2025 DESC;

WITH fam AS (
    SELECT family, sale_year,
           SUM(liters) AS liters, SUM(liters_retail) AS liters_retail
    FROM marts.county_category_year
    WHERE sale_year IN (2019, 2025)
    GROUP BY 1, 2
),
adults AS (   -- statewide adults, counted once per county
    SELECT sale_year, SUM(adults_21) AS adults FROM marts.county_year GROUP BY 1
),
lpa AS (
    SELECT family, sale_year,
           liters / adults        AS lpa_all,
           liters_retail / adults AS lpa_retail
    FROM fam JOIN adults USING (sale_year)
)
SELECT family,
       ROUND(MAX(lpa_retail) FILTER (WHERE sale_year = 2019), 2) AS lpa_retail_2019,
       ROUND(MAX(lpa_retail) FILTER (WHERE sale_year = 2025), 2) AS lpa_retail_2025,
       ROUND(100 * (POWER(MAX(lpa_retail) FILTER (WHERE sale_year = 2025)
                        / MAX(lpa_retail) FILTER (WHERE sale_year = 2019), 1.0 / 6) - 1), 1) AS cagr_retail_pct,
       ROUND(100 * (POWER(MAX(lpa_all) FILTER (WHERE sale_year = 2025)
                        / MAX(lpa_all) FILTER (WHERE sale_year = 2019), 1.0 / 6) - 1), 1)    AS cagr_all_pct
FROM lpa
GROUP BY family
ORDER BY cagr_retail_pct DESC;

SELECT county,
       ROUND(liters_per_adult, 2)        AS lpa_all,
       ROUND(liters_retail_per_adult, 2) AS lpa_retail,
       RANK() OVER (ORDER BY liters_per_adult DESC)        AS rank_all,
       RANK() OVER (ORDER BY liters_retail_per_adult DESC) AS rank_retail,
       ROUND(100 * (1 - liters_retail / NULLIF(liters, 0)), 1) AS supplier_share_pct
FROM marts.county_year
WHERE sale_year = 2025 AND county IS NOT NULL
ORDER BY rank_retail
LIMIT 20;
--WHERE sale_year = 2025 AND liters_retail < liters
--ORDER BY supplier_share_pct DESC;

  SELECT sale_year, ROUND(SUM(liters)) AS liters,
         ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml = 1000) / SUM(bottles_sold), 1) AS pct_1000,
         ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml < 750)  / SUM(bottles_sold), 1) AS pct_small
  FROM staging.sales_unique WHERE store_number = '5293' AND NOT flag_return
  GROUP BY 1 ORDER BY 1;
  
SELECT store_number, store_name, store_type,
       ROUND(SUM(liters) / COUNT(DISTINCT sale_year)) AS avg_liters_per_year,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml = 1000)  / SUM(bottles_sold), 1) AS pct_1000,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml >= 1750) / SUM(bottles_sold), 1) AS pct_1750_plus,
       ROUND(100.0 * SUM(bottles_sold) FILTER (WHERE bottle_ml < 750)   / SUM(bottles_sold), 1) AS pct_small
FROM staging.sales_unique s
JOIN staging.stores st USING (store_number)
WHERE NOT flag_return
GROUP BY 1, 2, 3
HAVING SUM(liters) / COUNT(DISTINCT sale_year) >= 20000
ORDER BY pct_1000 DESC
LIMIT 60;

WITH mix AS (
    SELECT s.store_number, st.county,
           SUM(s.liters) FILTER (WHERE s.sale_year = 2025) AS liters_2025,
           SUM(s.liters) / COUNT(DISTINCT s.sale_year) AS avg_liters,
           SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml = 1000)  / SUM(s.bottles_sold)::numeric AS p1000,
           SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml >= 1750) / SUM(s.bottles_sold)::numeric AS p1750,
           SUM(s.bottles_sold) FILTER (WHERE s.bottle_ml < 750)   / SUM(s.bottles_sold)::numeric AS psmall
    FROM staging.sales_unique s JOIN staging.stores st USING (store_number)
    WHERE NOT s.flag_return
    GROUP BY 1, 2
)
SELECT county,
       ROUND(100 * SUM(liters_2025) FILTER (WHERE avg_liters >= 20000 AND p1000 >= 0.60 AND p1750 < 0.10 AND psmall < 0.10)
             / SUM(liters_2025), 1) AS supplier_share_60,
       ROUND(100 * SUM(liters_2025) FILTER (WHERE avg_liters >= 20000 AND p1000 >= 0.50 AND p1750 < 0.10 AND psmall < 0.10)
             / SUM(liters_2025), 1) AS supplier_share_50
FROM mix
GROUP BY county
HAVING SUM(liters_2025) FILTER (WHERE avg_liters >= 20000 AND p1000 >= 0.50 AND p1750 < 0.10 AND psmall < 0.10) > 0
ORDER BY supplier_share_60 DESC NULLS LAST;