#!/usr/bin/env bash
set -euo pipefail
# Year -> Data Hub dataset ID. 2026 is confirmed; fill in the rest from the catalog.
declare -A IDS=( [2026]=1263 [2025]=1262 [2024]=1261 [2023]=1260 [2022]=1259
                 [2021]=1258 [2020]=1257 [2019]=1256 [2018]=1255 [2017]=1254 )
API="https://idh-be.iowa.gov/api/v1/datasets"
mkdir -p data/sales
for y in "${!IDS[@]}"; do
  echo "== $y (dataset ${IDS[$y]})"
  curl -L --fail -C - -o "data/sales/sales_$y.csv"    "$API/${IDS[$y]}/rows.csv"
  curl -L --fail      -o "data/sales/columns_$y.json" "$API/${IDS[$y]}/columns.json"
done