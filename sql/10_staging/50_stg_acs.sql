DROP TABLE IF EXISTS staging.acs_county;
CREATE TABLE staging.acs_county AS
SELECT
    vintage,
    (record->>'state') || (record->>'county') AS county_fips,
    UPPER(REPLACE(split_part(record->>'NAME', ',', 1), ' County', '')) AS county,
    (record->>'B01003_001E')::bigint AS population,
    (record->>'B01003_001E')::bigint - (
        SELECT SUM((record->>k)::bigint) FROM unnest(ARRAY[
            'B01001_003E','B01001_004E','B01001_005E','B01001_006E','B01001_007E','B01001_008E',
            'B01001_027E','B01001_028E','B01001_029E','B01001_030E','B01001_031E','B01001_032E']) AS k
    ) AS adults_21,
    CASE WHEN (record->>'B19013_001E')::numeric > 0 THEN (record->>'B19013_001E')::numeric END AS median_hh_income,
    CASE WHEN (record->>'B19301_001E')::numeric > 0 THEN (record->>'B19301_001E')::numeric END AS per_capita_income
FROM raw.acs
WHERE geo_level = 'county';

DROP TABLE IF EXISTS staging.acs_zcta;
CREATE TABLE staging.acs_zcta AS
SELECT
    vintage,
    record->>'zip code tabulation area' AS zcta,
    (record->>'B01003_001E')::bigint AS population,
    CASE WHEN (record->>'B19013_001E')::numeric > 0 THEN (record->>'B19013_001E')::numeric END AS median_hh_income
FROM raw.acs
WHERE geo_level = 'zcta'
  AND record->>'zip code tabulation area' BETWEEN '50000' AND '52999';  -- Iowa ZIPs start 50–52