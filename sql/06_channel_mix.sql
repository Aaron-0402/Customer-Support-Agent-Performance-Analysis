-- 06_channel_mix.sql
-- Share of each agent's tickets by channel (63 rows). Each agent's percentages add up to about 100.
WITH first_cte AS
(
SELECT agent_id, assigned_agent, channel, COUNT(*) AS channel_count_per_agent
FROM tickets_raw_staging
GROUP BY agent_id, assigned_agent, channel
),
second_cte AS
(
SELECT agent_id, COUNT(*) AS total_agent_tickets
FROM tickets_raw_staging
GROUP BY agent_id
)
SELECT f.agent_id, f.assigned_agent, f.channel, f.channel_count_per_agent,
       s.total_agent_tickets,
       ROUND(100.0 * f.channel_count_per_agent / s.total_agent_tickets, 1) AS channel_pct
FROM first_cte AS f
JOIN second_cte AS s ON f.agent_id = s.agent_id
ORDER BY f.agent_id, channel_pct DESC;
