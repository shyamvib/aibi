-- Query to get monthly orders from business intelligence integrated orders table
-- Using a subquery approach to work with Evidence's wrapping
SELECT * FROM (
    SELECT
        toStartOfMonth(toDateTime(order_date)) AS month,
        COUNT(*) AS order_count,
        SUM(total) AS total_amount,
        AVG(total) AS average_order_value
    FROM 
        business_intelligence.integrated_orders
    GROUP BY 
        month
    ORDER BY 
        month DESC
    LIMIT 12
) AS monthly_data
