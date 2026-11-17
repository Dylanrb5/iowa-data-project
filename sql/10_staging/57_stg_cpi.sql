DROP TABLE IF EXISTS staging.cpi;
CREATE TABLE staging.cpi (year INT PRIMARY KEY, cpi_u NUMERIC);
COPY staging.cpi FROM '/seeds/cpi_annual.csv' WITH (FORMAT csv, HEADER true);