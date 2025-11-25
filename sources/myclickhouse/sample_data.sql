-- Get a sample of data from the integrated_orders table
-- Using a SELECT query that will work with Evidence's wrapping
SELECT * FROM (
    SELECT * FROM business_intelligence.integrated_orders LIMIT 5
) AS sample_data
