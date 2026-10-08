-- 05_channel_category.sql
-- Which channel and category combinations are slowest?
-- HAVING hides groups with fewer than 10 tickets (44 rows remain).
SELECT channel,
       category,
       COUNT(resolution_time_hrs)         AS tickets_counted,
       ROUND(AVG(resolution_time_hrs), 1) AS avg_resolution_time
FROM tickets_raw_staging
GROUP BY channel, category
HAVING tickets_counted >= 10
ORDER BY avg_resolution_time DESC;
