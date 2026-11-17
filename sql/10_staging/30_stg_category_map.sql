DROP TABLE IF EXISTS staging.category_map;
CREATE TABLE staging.category_map (
    category_raw TEXT PRIMARY KEY, first_year INT, last_year INT, liters NUMERIC,
    category_clean TEXT NOT NULL, family TEXT NOT NULL
);
COPY staging.category_map FROM '/seeds/category_map.csv' WITH (FORMAT csv, HEADER true);

-- must return zero rows: every label in the data has a mapping
SELECT DISTINCT COALESCE(s.category_raw, '(missing)')
FROM staging.sales s
LEFT JOIN staging.category_map m ON m.category_raw = COALESCE(s.category_raw, '(missing)')
WHERE m.category_raw IS NULL;