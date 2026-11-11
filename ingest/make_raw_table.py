import csv
import re
import sys

path, table = sys.argv[1], sys.argv[2]
with open(path, newline="", encoding="utf-8-sig") as f:
    header = next(csv.reader(f))

def snake(name):
    return re.sub(r"[^0-9a-zA-Z]+", "_", name).strip("_").lower() or "col"

cols = [snake(h) for h in header]
dupes = {c for c in cols if cols.count(c) > 1}
if dupes:
    sys.exit(f"Duplicate column names after cleaning: {dupes}")

print(f"DROP TABLE IF EXISTS {table};")
print(f"CREATE TABLE {table} (")
print(",\n".join(f"    {c} TEXT" for c in cols))
print(");")