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
)
SELECT 
    formatDateTime(fo.first_order_date, '%Y-%m') as month_label,
    toStartOfMonth(fo.first_order_date) as month_date,
    multiIf(
        rc.contact_id IS NOT NULL, 'Repeat (2025)',
        'One-Timer (2025)'
    ) as customer_segment,
    multiIf(
        sc.contact_id IS NOT NULL, 'With Support',
        'No Support'
    ) as support_status,
    COUNT(DISTINCT fo.contact_id) as new_customers
FROM first_orders_2025 fo
LEFT JOIN repeat_customers rc ON toString(rc.contact_id) = toString(fo.contact_id)
LEFT JOIN supported_customers sc ON toString(sc.contact_id) = toString(fo.contact_id)
GROUP BY month_label, month_date, customer_segment, support_status
ORDER BY month_date, customer_segment, support_status
