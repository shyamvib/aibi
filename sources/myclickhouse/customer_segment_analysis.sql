-- Customer segment analysis for 2024
WITH customer_segment_2024 AS (
    SELECT 
        hubspot_id,
        MIN(CASE WHEN EXTRACT(YEAR FROM order_date) < 2024 THEN 1 ELSE 0 END) as is_pre_2024_customer,
        COUNT(DISTINCT sample_id) as order_count_2024,
        SUM(total) as total_revenue_2024
    FROM business_intelligence.integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2024
    AND hubspot_id IS NOT NULL
    AND sales_name IS NOT NULL
    AND sales_name != ''
    AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
    GROUP BY hubspot_id
)

-- Main query for customer segment analysis
SELECT 
    segment,
    year,
    customer_count,
    total_revenue,
    repeat_customers,
    one_time_customers,
    ROUND(total_revenue / NULLIF(customer_count, 0), 2) as avg_revenue_per_customer
FROM (
    -- Existing pre-2024: Customers who placed orders in 2024 but signed up before 2024
    SELECT 
        'Existing (Pre-2024)' as segment,
        '2024' as year,
        COUNT(DISTINCT hubspot_id) as customer_count,
        SUM(total_revenue_2024) as total_revenue,
        COUNT(DISTINCT CASE WHEN order_count_2024 > 1 THEN hubspot_id END) as repeat_customers,
        COUNT(DISTINCT CASE WHEN order_count_2024 = 1 THEN hubspot_id END) as one_time_customers
    FROM customer_segment_2024
    WHERE is_pre_2024_customer = 1
    
    UNION ALL
    
    -- One-timer 2024: Customers who placed exactly one order in 2024
    SELECT 
        'One-Timer (2024)' as segment,
        '2024' as year,
        COUNT(DISTINCT hubspot_id) as customer_count,
        SUM(total_revenue_2024) as total_revenue,
        0 as repeat_customers,
        COUNT(DISTINCT hubspot_id) as one_time_customers
    FROM customer_segment_2024
    WHERE is_pre_2024_customer = 0 
    AND order_count_2024 = 1
    
    UNION ALL
    
    -- Repeat 2024: Customers who placed multiple orders in 2024
    SELECT 
        'Repeat (2024)' as segment,
        '2024' as year,
        COUNT(DISTINCT hubspot_id) as customer_count,
        SUM(total_revenue_2024) as total_revenue,
        COUNT(DISTINCT hubspot_id) as repeat_customers,
        0 as one_time_customers
    FROM customer_segment_2024
    WHERE is_pre_2024_customer = 0 
    AND order_count_2024 > 1
) t
ORDER BY segment
