#!/usr/bin/env bash
# Rebuild the whole project from scratch: download, load raw, then staging, marts and analyses.
# Usage: ./scripts/build_all.sh   (run from the repo root; copy .env.example to .env first)
set -euo pipefail

[ -f .env ] || { echo "Missing .env: run 'cp .env.example .env' and fill it in."; exit 1; }
set -a; source .env; set +a
PSQL=(docker exec -i iowa_pg psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB")

# 0. Python environment (first run only) and database
[ -d .venv ] || { python3 -m venv .venv && .venv/bin/pip install -q -r requirements.txt; }
source .venv/bin/activate
docker compose up -d
until docker exec iowa_pg pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do sleep 2; done

# 1. download each year of sales (skips years already downloaded)
./scripts/download_sales.sh

# 2. raw layer: schemas and tables, then stream every yearly CSV part into raw.liquor_sales
./scripts/run_sql.sh sql/00_schemas.sql sql/01_raw_liquor_sales.sql
"${PSQL[@]}" -c "TRUNCATE raw.liquor_sales;"
for f in data/sales/*/*.csv; do
  echo "loading $f"
  "${PSQL[@]}" -c "COPY raw.liquor_sales FROM STDIN WITH (FORMAT csv, HEADER true);" < "$f"
done
"${PSQL[@]}" -c "SELECT COUNT(*) AS rows_loaded FROM raw.liquor_sales;"

# 3. Census ACS 5-year, county and ZCTA (pre-COVID vintage and latest)
(cd ingest && python download_acs.py 2019 2024)

# 4. staging, marts, analyses (seed files are loaded from /seeds inside these scripts)
./scripts/run_sql.sh sql/10_staging/*.sql sql/20_marts/*.sql sql/analysis/*.sql

echo "Done. Open dashboard/iowa-liquor.pbix in Power BI Desktop and click Refresh."