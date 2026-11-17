-- which category families grew in liters per adult, 2019 - 2025?
WITH fam AS (
    SELECT family, sale_year, SUM(liters) AS liters
    FROM marts.county_category_year
    WHERE sale_year IN (2019, 2025)
    GROUP BY 1, 2
),
adults AS (   -- statewide adults, counted once per county
    SELECT sale_year, SUM(adults_21) AS adults FROM marts.county_year GROUP BY 1
),
lpa AS (
    SELECT family, sale_year, liters / adults AS lpa FROM fam JOIN adults USING (sale_year)
)
SELECT family,
       MAX(lpa) FILTER (WHERE sale_year = 2019) AS lpa_2019,
       MAX(lpa) FILTER (WHERE sale_year = 2025) AS lpa_2025,
       POWER(MAX(lpa) FILTER (WHERE sale_year = 2025)
           / MAX(lpa) FILTER (WHERE sale_year = 2019), 1.0 / 6) - 1 AS cagr
FROM lpa
GROUP BY family
ORDER BY cagr DESC;

-- #1: Tequila/Mezcal, 5.8% yearly growth rate 