DROP TABLE IF EXISTS marts.county_category_year;
CREATE TABLE marts.county_category_year AS
WITH sales AS (
    SELECT st.county, m.family, s.sale_year, 
        SUM(s.liters) AS liters,
        SUM(s.liters) FILTER (WHERE NOT st.supplier_profile) AS liters_retail
    FROM staging.sales_unique s
    JOIN staging.stores st USING (store_number)
    JOIN staging.category_map m ON m.category_raw = COALESCE(s.category_raw, '(missing)')
    WHERE NOT s.flag_bad_date AND NOT s.flag_bad_volume
      AND s.sale_year < EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY 1, 2, 3
)
SELECT sa.*, cy.adults_21,
       sa.liters / NULLIF(cy.adults_21, 0) AS liters_per_adult,
       sa.liters_retail / NULLIF(cy.adults_21, 0) AS liters_retail_per_adult,
       sa.liters / SUM(sa.liters) OVER (PARTITION BY sa.county, sa.sale_year) AS share_of_county
FROM sales sa
JOIN marts.county_year cy USING (county, sale_year);