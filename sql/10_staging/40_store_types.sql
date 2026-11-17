DROP TABLE IF EXISTS staging.store_type_rules;
CREATE TABLE staging.store_type_rules (pattern TEXT, store_type TEXT, priority INT);
COPY staging.store_type_rules FROM '/seeds/store_type_rules.csv' WITH (FORMAT csv, HEADER true);

ALTER TABLE staging.stores ADD COLUMN IF NOT EXISTS store_type TEXT;
UPDATE staging.stores s SET store_type = r.store_type
FROM (SELECT DISTINCT ON (st.store_number) st.store_number, ru.store_type
      FROM staging.stores st
      JOIN staging.store_type_rules ru ON st.store_name ~ ru.pattern
      ORDER BY st.store_number, ru.priority) r
WHERE s.store_number = r.store_number;
UPDATE staging.stores SET store_type = 'other' WHERE store_type IS NULL;