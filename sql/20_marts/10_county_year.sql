DROP TABLE IF EXISTS marts.county_year;
CREATE TABLE marts.county_year AS
WITH params AS (
    SELECT (SELECT MAX(vintage) FROM staging.acs_county) AS latest_vintage,
           (SELECT cpi_u FROM staging.cpi ORDER BY year DESC LIMIT 1) AS base_cpi
),
sales AS (
    SELECT st.county, s.sale_year,
           SUM(s.liters) AS liters, 
           SUM(s.liters) FILTER (WHERE NOT st.supplier_profile) AS liters_retail,
           SUM(s.sale_dollars) AS dollars,
           COUNT(DISTINCT s.store_number) AS stores
    FROM staging.sales_unique s
    JOIN staging.stores st USING (store_number)
    WHERE NOT s.flag_bad_date AND NOT s.flag_bad_volume
      AND s.sale_year < EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY 1, 2
)
SELECT
    sa.county, sa.sale_year, sa.liters, sa.stores,
    ROUND(sa.dollars * p.base_cpi / c.cpi_u, 2) AS real_dollars,
    a.adults_21, a.median_hh_income,
    sa.liters / NULLIF(a.adults_21, 0) AS liters_per_adult,
    sa.liters_retail,
    sa.liters_retail / NULLIF(a.adults_21, 0) AS liters_retail_per_adult
FROM sales sa
CROSS JOIN params p
JOIN staging.cpi c ON c.year = sa.sale_year
LEFT JOIN staging.acs_county a
       ON a.county = sa.county
      AND a.vintage = CASE WHEN sa.sale_year <= 2019 THEN 2019 ELSE p.latest_vintage END;