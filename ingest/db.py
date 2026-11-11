import os
from dotenv import load_dotenv

load_dotenv()

def conninfo():
    return (
        f"host=localhost port={os.environ['POSTGRES_PORT']} "
        f"dbname={os.environ['POSTGRES_DB']} user={os.environ['POSTGRES_USER']} "
        f"password={os.environ['POSTGRES_PASSWORD']}"
    )