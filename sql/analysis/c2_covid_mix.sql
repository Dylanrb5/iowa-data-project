DROP TABLE IF EXISTS marts.covid_mix;
CREATE TABLE marts.covid_mix AS
WITH t AS (
    SELECT CASE WHEN sale_month BETWEEN '2018-03-01' AND '2020-02-01' THEN '1 baseline'
                WHEN sale_month BETWEEN '2020-03-01' AND '2021-02-01' THEN '2 covid year'
                WHEN sale_month >= '2022-01-01' THEN '3 recovery' END AS period,
           family, store_type, liters, bottles, avg_bottle_ml
    FROM marts.monthly
)
SELECT period, family,
       SUM(liters) / SUM(SUM(liters)) OVER (PARTITION BY period) AS share_of_liters,
       SUM(avg_bottle_ml * bottles) / SUM(bottles) AS avg_bottle_ml
FROM t WHERE period IS NOT NULL
GROUP BY 1, 2 ORDER BY 2, 1;