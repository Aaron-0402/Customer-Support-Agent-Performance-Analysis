-- 01_data_cleaning.sql
-- Cleaning script for the support ticket dataset (MySQL 8.0)
-- Works on a staging copy so the original table (tickets_raw) stays untouched.
-- Row count is the same before and after cleaning (1,924).

-- Creating a copy of the table and its data
CREATE TABLE tickets_raw_staging LIKE tickets_raw;

INSERT INTO tickets_raw_staging
SELECT * FROM tickets_raw;

-- 1. Inspect the data
SELECT COUNT(*) FROM tickets_raw_staging;
SELECT * FROM tickets_raw_staging LIMIT 20;

-- 2. Check for duplicates (SELECT only, nothing is deleted)
SELECT ticket_id, COUNT(*) AS copies
FROM tickets_raw_staging
GROUP BY ticket_id
HAVING COUNT(*) > 1;

-- 3. Standardize the values
-- ================= DATE AND TIME =================
-- Turn blanks into NULL first
UPDATE tickets_raw_staging SET created_at = NULL WHERE created_at = '';
UPDATE tickets_raw_staging SET resolved_at = NULL WHERE resolved_at = '';
-- Convert using the correct format
UPDATE tickets_raw_staging
    SET created_at = STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s'),
        resolved_at = STR_TO_DATE(resolved_at, '%Y-%m-%d %H:%i:%s');
-- Change the column types
ALTER TABLE tickets_raw_staging MODIFY COLUMN created_at DATETIME;
ALTER TABLE tickets_raw_staging MODIFY COLUMN resolved_at DATETIME;

-- ================= TRIMMING VALUES =================
UPDATE tickets_raw_staging
SET channel = TRIM(channel);

UPDATE tickets_raw_staging
    SET category = TRIM(category),
        subcategory = TRIM(subcategory),
        priority = TRIM(priority),
        status = TRIM(status),
        sentiment = TRIM(sentiment),
        product = TRIM(product),
        customer_plan = TRIM(customer_plan),
        region = TRIM(region),
        language = TRIM(language),
        message = TRIM(message);

-- ================= BLANK VALUES =================
UPDATE tickets_raw_staging SET resolution_note = NULL WHERE resolution_note = '';
UPDATE tickets_raw_staging SET resolution_time_hrs = NULL WHERE resolution_time_hrs = '';
UPDATE tickets_raw_staging SET csat_score = NULL WHERE csat_score = '';
UPDATE tickets_raw_staging SET first_response_time_hrs = NULL WHERE first_response_time_hrs = '';
UPDATE tickets_raw_staging SET reopened = NULL WHERE reopened = '';
UPDATE tickets_raw_staging SET escalated = NULL WHERE escalated = '';
UPDATE tickets_raw_staging SET num_interactions = NULL WHERE num_interactions = '';
UPDATE tickets_raw_staging SET customer_tenure_days = NULL WHERE customer_tenure_days = '';

-- ================= DROP COLUMN AND MODIFY VALUES =================
ALTER TABLE tickets_raw_staging DROP COLUMN message;

UPDATE tickets_raw_staging SET agent_id = REGEXP_SUBSTR(assigned_agent, '[0-9]+')
WHERE agent_id IS NULL OR agent_id = '';
