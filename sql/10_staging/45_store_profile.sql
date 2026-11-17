-- flag stores whose bottle mix looks like a bar/restaurant supplier
ALTER TABLE staging.stores ADD COLUMN IF NOT EXISTS supplier_profile BOOLEAN;
UPDATE staging.stores SET supplier_profile = false;

UPDATE staging.stores st
SET supplier_profile = true
FROM (
    SELECT store_number
    FROM staging.sales_unique
    WHERE NOT flag_return
    GROUP BY store_number
    HAVING SUM(liters) / COUNT(DISTINCT sale_year) >= 20000
        AND SUM(bottles_sold) FILTER (WHERE bottle_ml = 1000)  >= 0.60 * SUM(bottles_sold)
        AND SUM(bottles_sold) FILTER (WHERE bottle_ml >= 1750) <  0.10 * SUM(bottles_sold)
        AND SUM(bottles_sold) FILTER (WHERE bottle_ml < 750)   <  0.10 * SUM(bottles_sold)
) x
WHERE st.store_number = x.store_number;

SELECT supplier_profile, COUNT(*) FROM staging.stores GROUP BY 1;   -- 15 returned