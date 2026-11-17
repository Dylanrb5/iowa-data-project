DROP TABLE IF EXISTS marts.store_category_gaps;
CREATE TABLE marts.store_category_gaps AS
WITH grp AS (   -- the same stores and peer groups as marts.store_peers
    SELECT store_number, store_name, store_type, peer_type, area_class, income_tercile, county,
           dollars AS store_dollars
    FROM marts.store_peers
),
fam AS (   -- dollars, not liters: multipack minis understate liters for some families
    SELECT s.store_number, m.family, SUM(s.sale_dollars) AS dollars
    FROM staging.sales_unique s
    JOIN staging.category_map m ON m.category_raw = COALESCE(s.category_raw, '(missing)')
    WHERE s.sale_year = 2025 AND NOT s.flag_bad_volume
    GROUP BY 1, 2
),
grid AS (   -- every store x family, with 0 where the store sold none
    SELECT g.*, f.family,
           COALESCE(x.dollars, 0) AS family_dollars,
           COALESCE(x.dollars, 0) / NULLIF(g.store_dollars, 0) AS family_share
    FROM grp g
    CROSS JOIN (SELECT DISTINCT family FROM staging.category_map WHERE family <> 'Other') f
    LEFT JOIN fam x ON x.store_number = g.store_number AND x.family = f.family
),
peer AS (
    SELECT peer_type, area_class, income_tercile, family,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY family_share) AS peer_share,
           COUNT(*) AS peer_n
    FROM grid GROUP BY 1, 2, 3, 4
)
SELECT g.store_number, g.store_name, g.store_type, g.peer_type, g.area_class, g.county, g.family,
       g.store_dollars, g.family_dollars,
       ROUND(g.family_share::numeric, 3) AS family_share,
       ROUND(p.peer_share::numeric, 3)   AS peer_share,
       g.store_dollars * p.peer_share    AS expected_dollars,
       GREATEST(g.store_dollars * p.peer_share - g.family_dollars, 0) AS gap_dollars,
       (g.family_dollars < 0.5 * g.store_dollars * p.peer_share
        AND g.store_dollars * p.peer_share >= 2000      -- ignore tiny expected sales (about 100 L)
        AND p.peer_n >= 10) AS flag_mix_gap
FROM grid g
JOIN peer p USING (peer_type, area_class, income_tercile, family);


-- which families are most often under-stocked, and how many dollars the gaps add up to
SELECT family,
       COUNT(*) FILTER (WHERE flag_mix_gap) AS stores_with_gap,
       ROUND(SUM(gap_dollars) FILTER (WHERE flag_mix_gap)) AS gap_dollars
FROM marts.store_category_gaps
GROUP BY family
ORDER BY gap_dollars DESC;

-- the biggest single gaps in the fastest-growing family (Part A)
SELECT store_name, county, store_type, ROUND(family_dollars) AS tequila_dollars,
       ROUND(expected_dollars) AS expected_dollars, ROUND(gap_dollars) AS gap_dollars,
       family_share, peer_share
FROM marts.store_category_gaps
WHERE family = 'Tequila/Mezcal' AND flag_mix_gap
ORDER BY gap_dollars DESC
LIMIT 20;

-- stores that are small overall AND missing the growing category: the most concrete targets
SELECT g.store_name, g.county, ROUND(p.ratio_dollars::numeric, 2) AS ratio_dollars, ROUND(g.gap_dollars) AS tequila_gap_dollars
FROM marts.store_category_gaps g
JOIN marts.store_peers p USING (store_number)
WHERE g.family = 'Tequila/Mezcal' AND g.flag_mix_gap AND p.flag_under
ORDER BY g.gap_dollars DESC;