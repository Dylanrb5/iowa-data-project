DROP TABLE IF EXISTS marts.store_year;
CREATE TABLE marts.store_year AS
WITH sales AS (
    SELECT store_number,
           sale_year,
           SUM(liters) AS liters,
           SUM(sale_dollars) AS dollars,
           -- price per liter on non-multipack rows only (multipack liters are understated)
           SUM(sale_dollars) FILTER (WHERE NOT flag_multipack)
             / NULLIF(SUM(liters) FILTER (WHERE NOT flag_multipack), 0) AS price_per_liter,
           SUM(sale_dollars) FILTER (WHERE flag_multipack) / NULLIF(SUM(sale_dollars), 0) AS multipack_dollar_share,
           COUNT(DISTINCT sale_month) AS active_months
    FROM staging.sales_unique
    WHERE NOT flag_bad_date AND NOT flag_bad_volume
      AND sale_year < EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY 1, 2
)
SELECT sa.*, st.store_name, st.store_type, st.supplier_profile, st.county, st.zcta, st.urban_rural, st.lat, st.lon,
       z.population AS zcta_population, z.median_hh_income AS zcta_income,
       COUNT(*) OVER (PARTITION BY sa.store_number) AS years_active
FROM sales sa
JOIN staging.stores st USING (store_number)
LEFT JOIN staging.acs_zcta z
       ON z.zcta = st.zcta AND z.vintage = (SELECT MAX(vintage) FROM staging.acs_zcta);