-- 07_priority_mix.sql
-- Share of each agent's tickets in each priority level (36 rows).
WITH first_cte AS
(
SELECT agent_id, assigned_agent, priority, COUNT(*) AS priority_count_per_agent
FROM tickets_raw_staging
GROUP BY agent_id, assigned_agent, priority
),
second_cte AS
(
SELECT agent_id, COUNT(*) AS total_agent_tickets
FROM tickets_raw_staging
GROUP BY agent_id
)
SELECT f.agent_id, f.assigned_agent, f.priority, f.priority_count_per_agent,
       s.total_agent_tickets,
       ROUND(100.0 * f.priority_count_per_agent / s.total_agent_tickets, 1) AS priority_pct
FROM first_cte AS f
JOIN second_cte AS s ON f.agent_id = s.agent_id
ORDER BY f.agent_id, FIELD(f.priority, 'Critical', 'High', 'Medium', 'Low');
