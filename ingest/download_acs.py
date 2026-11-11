import os
import sys

import psycopg
import requests
from psycopg.types.json import Jsonb

from db import conninfo

KEY = os.environ["CENSUS_API_KEY"]
UNDER21 = [f"B01001_{i:03d}E" for i in [*range(3, 9), *range(27, 33)]]
VARS = ["NAME", "B01003_001E", "B19013_001E", "B19301_001E", *UNDER21]

def fetch(year, geo):
    params = {"get": ",".join(VARS), "key": KEY}
    if geo == "county":
        params.update({"for": "county:*", "in": "state:19"})  # 19 = Iowa
    else:
        params["for"] = "zip code tabulation area:*"  # national; filtered to Iowa later
    r = requests.get(f"https://api.census.gov/data/{year}/acs/acs5", params=params, timeout=180)
    r.raise_for_status()
    rows = r.json()
    return rows[0], rows[1:]

years = [int(y) for y in sys.argv[1:]]
with psycopg.connect(conninfo()) as conn:
    conn.execute(
        "CREATE TABLE IF NOT EXISTS raw.acs (vintage INT, geo_level TEXT, "
        "record JSONB, loaded_at TIMESTAMPTZ DEFAULT now())"
    )
    for year in years:
        for geo in ("county", "zcta"):
            header, rows = fetch(year, geo)
            conn.execute("DELETE FROM raw.acs WHERE vintage = %s AND geo_level = %s", (year, geo))
            with conn.cursor() as cur:
                cur.executemany(
                    "INSERT INTO raw.acs (vintage, geo_level, record) VALUES (%s, %s, %s)",
                    [(year, geo, Jsonb(dict(zip(header, r)))) for r in rows],
                )
            conn.execute(
                "INSERT INTO raw.load_log (source, file_name, row_count) VALUES (%s, %s, %s)",
                (f"acs5_{geo}", str(year), len(rows)),
            )
            print(year, geo, len(rows), "rows")