-- 02_agent_scorecard.sql
-- One row per agent: counts, rates, ranks and averages.
-- Rates use tickets that reached an outcome (fixed + escalated); NULLIF avoids division by zero.
-- The ORDER BY inside RANK() decides how ranks are assigned, so it stays.
WITH agent_fixed_escalation AS
(
SELECT agent_id, assigned_agent,
    COUNT(CASE WHEN escalated = 'False'
               AND status IN ('Resolved','Closed') THEN 1 END)    AS total_fixed,
    COUNT(CASE WHEN escalated = 'False'
               AND status IN ('Open','In Progress') THEN 1 END)   AS total_still_open,
    COUNT(CASE WHEN escalated = 'True' THEN 1 END)                AS total_escalated,
    COUNT(*)                                                      AS total_agent_handled,
    AVG(first_response_time_hrs) AS avg_frh,
    AVG(resolution_time_hrs)     AS avg_rth,
    AVG(csat_score)              AS avg_csatscore
FROM tickets_raw_staging
GROUP BY agent_id, assigned_agent
)
SELECT agent_id, assigned_agent, total_fixed, total_still_open, total_escalated,
    total_agent_handled,
    ROUND(100.0 * total_fixed     / NULLIF(total_fixed + total_escalated, 0), 1) AS fixed_rate_pct,
    ROUND(100.0 * total_escalated / NULLIF(total_fixed + total_escalated, 0), 1) AS escalated_rate_pct,
    RANK() OVER (ORDER BY 1.0 * total_fixed
                 / NULLIF(total_fixed + total_escalated, 0) DESC)     AS agent_rank_in_fixed,
    RANK() OVER (ORDER BY 1.0 * total_escalated
                 / NULLIF(total_fixed + total_escalated, 0) DESC)     AS agent_rank_in_escalation,
    ROUND(avg_frh, 1)       AS avg_response_time,
    ROUND(avg_rth, 1)       AS avg_resolution_time,
    ROUND(avg_csatscore, 1) AS avg_csat_score
FROM agent_fixed_escalation
ORDER BY agent_id ASC;
