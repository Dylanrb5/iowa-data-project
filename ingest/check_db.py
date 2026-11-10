import os
import psycopg
from dotenv import load_dotenv

load_dotenv()

conninfo = (
    f"host=localhost port={os.environ['POSTGRES_PORT']} "
    f"dbname={os.environ['POSTGRES_DB']} "
    f"user={os.environ['POSTGRES_USER']} "
    f"password={os.environ['POSTGRES_PASSWORD']}"
)

with psycopg.connect(conninfo) as conn:
    rows = conn.execute(
        "SELECT schema_name FROM information_schema.schemata "
        "WHERE schema_name IN ('raw', 'staging', 'marts') ORDER BY 1"
    ).fetchall()
    print("Connected. Schemas:", [r[0] for r in rows])