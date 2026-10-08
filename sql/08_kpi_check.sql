-- 08_kpi_check.sql
-- One query that checks every dashboard KPI against the raw table.
-- Expected: 1924 | 1280 | 532 | 112 | 92.0 | 8.0 | 12.1 | 58.4 | 2.7
SELECT COUNT(*) AS total_tickets,
       SUM(escalated = 'False' AND status IN ('Resolved','Closed'))  AS fixed_by_agent,
       SUM(escalated = 'False' AND status IN ('Open','In Progress')) AS still_open,
       SUM(escalated = 'True')                                       AS escalated,
       ROUND(100.0 * SUM(escalated = 'False' AND status IN ('Resolved','Closed'))
             / (SUM(escalated = 'False' AND status IN ('Resolved','Closed'))
                + SUM(escalated = 'True')), 1)                       AS fixed_rate_pct,
       ROUND(100.0 * SUM(escalated = 'True')
             / (SUM(escalated = 'False' AND status IN ('Resolved','Closed'))
                + SUM(escalated = 'True')), 1)                       AS escalation_rate_pct,
       ROUND(AVG(first_response_time_hrs), 1) AS avg_first_response_hrs,
       ROUND(AVG(resolution_time_hrs), 1)     AS avg_resolution_hrs,
       ROUND(AVG(csat_score), 1)              AS avg_csat
FROM tickets_raw_staging;
