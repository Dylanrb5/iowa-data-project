ALTER TABLE staging.stores ADD COLUMN IF NOT EXISTS zcta TEXT;
UPDATE staging.stores s SET zcta = s.zip5
WHERE EXISTS (SELECT 1 FROM staging.acs_zcta z WHERE z.zcta = s.zip5);

SELECT COUNT(*) FILTER (WHERE zcta IS NULL) AS unmatched, COUNT(*) AS stores
FROM staging.stores;