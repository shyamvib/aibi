WITH first_orders_2025 AS (
    SELECT 
        contact_id,
        MIN(touchpoint_date) as first_order_date
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_type = 'First Order'
    AND EXTRACT(YEAR FROM touchpoint_date) = 2025
    GROUP BY contact_id
),
repeat_customers AS (
    SELECT DISTINCT contact_id
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_type = 'Repeat Order'
),
supported_customers AS (
    SELECT DISTINCT contact_id
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_category IN ('Sales Activity', 'Clinical Activity')
),
all_2025_customers AS (
    SELECT DISTINCT
        toString(hubspot_id) as contact_id,
        sales_name as rsm_name
    FROM business_intelligence.integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2025
    AND hubspot_id IS NOT NULL
    AND sales_name IS NOT NULL
    AND sales_name != ''
)
SELECT 
    ac.rsm_name,
    multiIf(
        fo.contact_id IS NULL, 'Existing (Pre-2025)',
        rc.contact_id IS NOT NULL, 'Repeat (2025)',
        'One-Timer (2025)'
    ) as customer_segment,
    multiIf(
        sc.contact_id IS NOT NULL, 'With Support',
        'No Support'
    ) as support_status,
    
    -- Product Details
    COALESCE(fot.bundle_name, 'No Bundle') as bundle_name,
    fot.test_name,
    fot.test_type,
    
    -- Metrics
    COUNT(DISTINCT ac.contact_id) as customers_ordering,
    COUNT(*) as times_ordered,
    ROUND(SUM(fot.base_price), 2) as total_test_value,
    ROUND(AVG(fot.base_price), 2) as avg_test_price
    
FROM all_2025_customers ac
LEFT JOIN first_orders_2025 fo ON toString(fo.contact_id) = ac.contact_id
LEFT JOIN repeat_customers rc ON toString(rc.contact_id) = ac.contact_id
LEFT JOIN supported_customers sc ON toString(sc.contact_id) = ac.contact_id
INNER JOIN business_intelligence.integrated_orders io 
    ON toString(io.hubspot_id) = ac.contact_id
LEFT JOIN business_intelligence.fact_orders_tests fot
    ON io.sample_id = fot.sample_id
WHERE EXTRACT(YEAR FROM io.order_date) = 2025
AND fot.test_name IS NOT NULL
GROUP BY 
    ac.rsm_name, customer_segment, support_status,
    bundle_name, fot.test_name, fot.test_type
ORDER BY 
    ac.rsm_name, customer_segment, times_ordered DESC
