DROP TABLE IF EXISTS marts.covid_monthly;
CREATE TABLE marts.covid_monthly AS
WITH m AS (   -- one series for all stores, and one each for retail and bar-supplier stores
    SELECT sale_month,
           CASE WHEN supplier_profile THEN 'bar-supplier stores' ELSE 'retail stores' END AS segment,
           SUM(liters) AS liters
    FROM marts.monthly GROUP BY 1, 2
    UNION ALL
    SELECT sale_month, 'all stores', SUM(liters) FROM marts.monthly GROUP BY 1
),
base AS (
    SELECT segment, EXTRACT(MONTH FROM sale_month) AS mo, AVG(liters) AS base_liters
    FROM m WHERE sale_month BETWEEN '2018-03-01' AND '2020-02-01'
    GROUP BY 1, 2
)
SELECT m.sale_month, m.segment, m.liters,
       100 * m.liters / b.base_liters AS index_vs_baseline,
       CASE WHEN m.sale_month < '2020-03-01' THEN 'baseline'
            WHEN m.sale_month < '2021-03-01' THEN 'covid year'
            WHEN m.sale_month < '2022-01-01' THEN 'transition'
            ELSE 'recovery' END AS period,
       CASE WHEN m.sale_month < '2020-03-01' THEN 1
     		WHEN m.sale_month < '2021-03-01' THEN 2
     		WHEN m.sale_month < '2022-01-01' THEN 3
     		ELSE 4 END AS period_order
FROM m JOIN base b ON b.segment = m.segment AND EXTRACT(MONTH FROM m.sale_month) = b.mo
ORDER BY 2, 1;

-- side by side month
SELECT sale_month,
       ROUND(MAX(index_vs_baseline) FILTER (WHERE segment = 'all stores'))          AS all_stores,
       ROUND(MAX(index_vs_baseline) FILTER (WHERE segment = 'retail stores'))       AS retail,
       ROUND(MAX(index_vs_baseline) FILTER (WHERE segment = 'bar-supplier stores')) AS bar_suppliers
FROM marts.covid_monthly
WHERE sale_month BETWEEN '2019-07-01' AND '2022-06-01'
GROUP BY 1 ORDER BY 1;

-- averages by period
SELECT period, segment,
       ROUND(AVG(index_vs_baseline), 1) AS avg_index,
       COUNT(*) AS months
FROM marts.covid_monthly
GROUP BY 1, 2
ORDER BY MIN(sale_month), segment;

-- peaks and lows
SELECT DISTINCT ON (segment) segment, sale_month AS lowest_month, ROUND(index_vs_baseline) AS index
FROM marts.covid_monthly
WHERE period = 'covid year'
ORDER BY segment, index_vs_baseline;

-- did it last
SELECT EXTRACT(YEAR FROM sale_month)::int AS yr, segment,
       ROUND(AVG(index_vs_baseline), 1) AS avg_index
FROM marts.covid_monthly
WHERE sale_month >= '2019-01-01' AND sale_month < '2026-01-01'
GROUP BY 1, 2
ORDER BY 2, 1;