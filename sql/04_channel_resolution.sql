-- 04_channel_resolution.sql
-- Average resolution time by channel (7 rows).
-- NOTE: reconstructed from the session output; replace with your own version if it differs.
SELECT channel,
       COUNT(resolution_time_hrs)         AS channel_counted,
       ROUND(AVG(resolution_time_hrs), 1) AS avg_resolution_time
FROM tickets_raw_staging
GROUP BY channel
ORDER BY avg_resolution_time DESC;
