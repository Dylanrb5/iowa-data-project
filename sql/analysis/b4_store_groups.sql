-- labels every store in marts.store_peers with what explains its result.
-- manual review decisions are in seeds/store_review.csv
-- and override the rules below.

DROP TABLE IF EXISTS staging.store_review;
CREATE TABLE staging.store_review (store_number TEXT PRIMARY KEY, store_group TEXT, note TEXT);
COPY staging.store_review FROM '/seeds/store_review.csv' WITH (FORMAT csv, HEADER true);

ALTER TABLE marts.store_peers
    ADD COLUMN IF NOT EXISTS store_group TEXT,
    ADD COLUMN IF NOT EXISTS review_note TEXT;

UPDATE marts.store_peers p
SET store_group = COALESCE(
        (SELECT r.store_group FROM staging.store_review r WHERE r.store_number = p.store_number),
        CASE WHEN p.new_store AND p.ratio_dollars < 0.5         THEN 'new entrant'
             WHEN NOT p.flag_under                              THEN 'not flagged'
             WHEN p.first_year = 2023                           THEN 'post-opening decline'
             WHEN p.store_name ~ 'HY-?VEE|TARGET|WAL-?MART'     THEN 'chain format'
             WHEN p.price_per_liter >= 35 OR p.price_per_liter < 13 THEN 'price position'
             ELSE 'candidate' END),
    review_note = (SELECT r.note FROM staging.store_review r WHERE r.store_number = p.store_number);

-- final counts for the memo
SELECT store_group,
       COUNT(*)                                         AS stores,
       ROUND(SUM(dollars))                              AS dollars_2025,
       ROUND(SUM(peer_median_dollars - dollars))        AS gap_to_peer_median,
       ROUND(SUM(0.5 * peer_median_dollars - dollars))  AS gap_to_half_median
FROM marts.store_peers
WHERE store_group <> 'not flagged'
GROUP BY store_group
ORDER BY stores DESC;