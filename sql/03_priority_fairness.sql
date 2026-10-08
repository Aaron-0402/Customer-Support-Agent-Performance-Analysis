-- 03_priority_fairness.sql
-- Fairness check: average resolution time per agent within each priority (36 rows).
-- COUNT of the same column as the AVG shows how many tickets each average rests on.
SELECT agent_id,
       assigned_agent,
       priority,
       COUNT(resolution_time_hrs)         AS tickets_counted,
       ROUND(AVG(resolution_time_hrs), 1) AS avg_resolution_time
FROM tickets_raw_staging
GROUP BY agent_id, assigned_agent, priority
ORDER BY FIELD(priority, 'Critical', 'High', 'Medium', 'Low'),  -- custom priority order
         avg_resolution_time ASC,                                -- fastest agent first
         agent_id;                                               -- tie-breaker
