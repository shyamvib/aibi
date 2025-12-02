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
        sales_name as rsm_name,
        state, 
        customer_credential
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
    
    -- Profile Dimensions
    COALESCE(ac.customer_credential, 'Unknown') as credential,
    COALESCE(ac.state, 'Unknown') as state,
    years_in_practice,
    COALESCE(hc.practice_structure, 'Not Specified') as practice_structure,
    COALESCE(hc.provider_lead_source, 'Unknown') as referral_source,
    COALESCE(hc.test_interested_in, 'Not Specified') as tests_interested_in,
    COALESCE(hc.competitors_used, 'Not Specified') as competitors_used,
    COALESCE(hc.samples_per_week, 'Not Specified') as samples_per_week,
    COALESCE(hc.hs_latest_source, 'Unknown') as hs_latest_source,
    
    -- Metrics
    COUNT(DISTINCT ac.contact_id) as customer_count,
    ROUND(SUM(io.total), 2) as revenue,
    ROUND(SUM(io.total) / COUNT(DISTINCT ac.contact_id), 2) as revenue_per_customer
    
FROM all_2025_customers ac
LEFT JOIN first_orders_2025 fo ON toString(fo.contact_id) = ac.contact_id
LEFT JOIN repeat_customers rc ON toString(rc.contact_id) = ac.contact_id
LEFT JOIN supported_customers sc ON toString(sc.contact_id) = ac.contact_id
INNER JOIN business_intelligence.integrated_orders io 
    ON toString(io.hubspot_id) = ac.contact_id
LEFT JOIN business_intelligence.bi_hubspot_contacts hc
    ON toString(hc.contact_id) = ac.contact_id
WHERE EXTRACT(YEAR FROM io.order_date) = 2025
GROUP BY 
    ac.rsm_name, customer_segment, support_status,
    credential, state, provider_type, years_in_practice,
    practice_structure, referral_source, tests_interested_in,
    competitors_used, samples_per_week, hs_latest_source
ORDER BY 
    ac.rsm_name, customer_segment, revenue DESC
