-- Get table structure from system tables instead of using DESCRIBE TABLE
SELECT 
    name AS column_name,
    type AS data_type,
    default_expression,
    comment
FROM system.columns
WHERE database = 'business_intelligence' AND table = 'integrated_orders'
