-- totals reconcile: mart liters = staging liters (same filters)
SELECT (SELECT SUM(liters) FROM marts.county_year) AS mart,
       (SELECT SUM(s.liters) FROM staging.sales_unique s JOIN staging.stores st USING (store_number)
        WHERE NOT flag_bad_date AND NOT flag_bad_volume
          AND sale_year < EXTRACT(YEAR FROM CURRENT_DATE)) AS staging;

-- every county has Census data every year? (99 counties)
SELECT sale_year, COUNT(*) AS counties, COUNT(*) FILTER (WHERE adults_21 IS NULL) AS missing_census
FROM marts.county_year GROUP BY 1 ORDER BY 1;

-- does liters per adult look plausible? Highest and lowest counties
(SELECT county, liters_per_adult FROM marts.county_year WHERE sale_year = 2019 ORDER BY 2 DESC LIMIT 5)
UNION ALL
(SELECT county, liters_per_adult FROM marts.county_year WHERE sale_year = 2019 ORDER BY 2 ASC LIMIT 5);
-- top 3: dickinson, cerro gordo, polk

-- yearly statewide liters per adult, and county median
SELECT sale_year,
       ROUND(SUM(liters) / SUM(adults_21), 2) AS statewide_liters_per_adult,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY liters_per_adult)::numeric, 2) AS median_county
FROM marts.county_year
GROUP BY 1 ORDER BY 1;

