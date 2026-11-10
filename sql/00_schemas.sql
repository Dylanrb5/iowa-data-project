CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;

CREATE TABLE IF NOT EXISTS raw.load_log (
    load_id     SERIAL PRIMARY KEY,
    source      TEXT NOT NULL,
    file_name   TEXT,
    row_count   BIGINT,
    loaded_at   TIMESTAMPTZ DEFAULT now(),
    notes       TEXT
);