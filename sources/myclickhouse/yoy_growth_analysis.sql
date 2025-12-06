-- Year-over-Year Growth Analysis
WITH yearly_metrics AS (
    -- 2023 data
    SELECT 
        '2023' as year,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT sample_id) as total_orders,
        SUM(total) as total_revenue,
        1 as sort_order
    FROM business_intelligence.integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2023
    --AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
    
    UNION ALL
    
    -- 2024 data
    SELECT 
        '2024' as year,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT sample_id) as total_orders,
        SUM(total) as total_revenue,
        2 as sort_order
    FROM business_intelligence.integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2024
    --AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
    
    UNION ALL
    
    -- 2025 data
    SELECT 
        '2025' as year,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT sample_id) as total_orders,
        SUM(total) as total_revenue,
        3 as sort_order
    FROM business_intelligence.integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2025
    --AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
),

totals AS (
    SELECT 
        'All Years' as year,
        COUNT(DISTINCT customer_id) as unique_customers,
        COUNT(DISTINCT sample_id) as total_orders,
        SUM(total) as total_revenue,
        4 as sort_order
    FROM business_intelligence.integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) BETWEEN 2023 AND 2025
    --AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
)

SELECT 
    year,
    unique_customers,
    total_orders,
    total_revenue
FROM (
    SELECT * FROM yearly_metrics
    UNION ALL
    SELECT * FROM totals
) t
ORDER BY sort_order
