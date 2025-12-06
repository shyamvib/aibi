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
calls_meetings AS (
    SELECT 
        contact_id,
        EXTRACT(YEAR FROM touchpoint_date) as year,
        EXTRACT(MONTH FROM touchpoint_date) as month,
        countIf(touchpoint_type = 'Call') as calls,
        countIf(touchpoint_type = 'Meeting') as meetings
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_type IN ('Call', 'Meeting')
    AND EXTRACT(YEAR FROM touchpoint_date) = 2025
    GROUP BY contact_id, year, month
),
all_2025_customers AS (
    SELECT DISTINCT
        toString(hubspot_id) as contact_id,
        sales_name as rsm_name,
        state
    FROM business_intelligence.canonical_integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2025
    AND hubspot_id IS NOT NULL
    AND sales_name IS NOT NULL
    AND sales_name != ''
)
SELECT 
    EXTRACT(YEAR FROM io.order_date) as year,
    EXTRACT(MONTH FROM io.order_date) as month_number,
    formatDateTime(io.order_date, '%Y-%m') as month_label,
    toStartOfMonth(io.order_date) as month_date,
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
    COUNT(DISTINCT ac.contact_id) as active_customers_this_month,
    COUNT(DISTINCT io.sample_id) as orders,
    ROUND(SUM(io.total), 2) as revenue,
    ROUND(SUM(io.total) / COUNT(DISTINCT io.sample_id), 2) as aov,
    SUM(cm.calls) as total_calls,
    SUM(cm.meetings) as total_meetings
FROM all_2025_customers ac
LEFT JOIN first_orders_2025 fo ON toString(fo.contact_id) = ac.contact_id
LEFT JOIN repeat_customers rc ON toString(rc.contact_id) = ac.contact_id
LEFT JOIN supported_customers sc ON toString(sc.contact_id) = ac.contact_id
INNER JOIN business_intelligence.canonical_integrated_orders io 
    ON toString(io.hubspot_id) = ac.contact_id
LEFT JOIN calls_meetings cm 
    ON toString(cm.contact_id) = ac.contact_id 
    AND EXTRACT(YEAR FROM io.order_date) = cm.year
    AND EXTRACT(MONTH FROM io.order_date) = cm.month
WHERE EXTRACT(YEAR FROM io.order_date) = 2025
GROUP BY 
    year,
    month_number,
    month_label,
    month_date,
    ac.rsm_name, 
    customer_segment, 
    support_status
ORDER BY 
    month_date,
    ac.rsm_name, 
    customer_segment, 
    support_status DESC
