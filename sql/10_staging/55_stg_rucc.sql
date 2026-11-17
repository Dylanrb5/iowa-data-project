DROP TABLE IF EXISTS staging.rucc;
CREATE TABLE staging.rucc (county_fips TEXT PRIMARY KEY, rucc INT);
COPY staging.rucc FROM '/seeds/rucc_iowa.csv' WITH (FORMAT csv, HEADER true);

ALTER TABLE staging.stores ADD COLUMN IF NOT EXISTS urban_rural TEXT;
UPDATE staging.stores s
SET urban_rural = CASE WHEN r.rucc <= 3 THEN 'metro' ELSE 'non-metro' END
FROM staging.rucc r
WHERE r.county_fips = s.county_fips;

-- only 3 null, rest are non-metro (1395) or metro (1734)
SELECT urban_rural, COUNT(*) FROM staging.stores GROUP BY 1;