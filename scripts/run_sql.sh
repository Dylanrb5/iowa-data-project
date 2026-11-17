#!/usr/bin/env bash
set -euo pipefail
set -a; source .env; set +a
for f in "$@"; do
  echo "== $f"
  docker exec -i iowa_pg psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" < "$f"
done