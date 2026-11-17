DROP TABLE IF EXISTS marts.monthly;
CREATE TABLE marts.monthly AS
SELECT s.sale_month, m.family, st.store_type, st.urban_rural, st.supplier_profile,
       SUM(s.liters) AS liters, SUM(s.sale_dollars) AS dollars, SUM(s.bottles_sold) AS bottles,
       SUM(s.bottle_ml * s.bottles_sold) / NULLIF(SUM(s.bottles_sold), 0) AS avg_bottle_ml
FROM staging.sales_unique s
JOIN staging.stores st USING (store_number)
JOIN staging.category_map m ON m.category_raw = COALESCE(s.category_raw, '(missing)')
WHERE NOT s.flag_bad_date AND NOT s.flag_bad_volume AND NOT s.flag_bad_qty
GROUP BY 1, 2, 3, 4, 5;