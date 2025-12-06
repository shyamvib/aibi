-- WITH first_orders_2025 AS (
--     SELECT 
--         contact_id,
--         MIN(touchpoint_date) as first_order_date
--     FROM business_intelligence.customer_journey_final
--     WHERE touchpoint_type = 'First Order'
--     AND EXTRACT(YEAR FROM touchpoint_date) = 2025
--     GROUP BY contact_id
-- ),
-- repeat_customers AS (
--     SELECT DISTINCT contact_id
--     FROM business_intelligence.customer_journey_final
--     WHERE touchpoint_type = 'Repeat Order'
-- ),
-- supported_customers AS (
--     SELECT DISTINCT contact_id
--     FROM business_intelligence.customer_journey_final
--     WHERE touchpoint_category IN ('Sales Activity', 'Clinical Activity')
-- ),
-- calls_meetings_data AS (
--     SELECT 
--         contact_id,
--         countIf(touchpoint_type = 'Call') as calls,
--         countIf(touchpoint_type = 'Meeting') as meetings
--     FROM business_intelligence.customer_journey_final
--     WHERE touchpoint_type IN ('Call', 'Meeting')
--     AND EXTRACT(YEAR FROM touchpoint_date) = 2025
--     GROUP BY contact_id
-- ),
-- all_2025_customers AS (
--     SELECT DISTINCT
--         toString(hubspot_id) as contact_id,
--         sales_name as rsm_name,
--         state
--     FROM business_intelligence.canonical_integrated_orders
--     WHERE EXTRACT(YEAR FROM order_date) = 2025
--     AND hubspot_id IS NOT NULL
--     AND sales_name IS NOT NULL
--     AND sales_name != ''
--     --AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
-- ),
-- -- Customer segment analysis for 2024
-- customer_segment_2024 AS (
--     SELECT 
--         hubspot_id,
--         MIN(CASE WHEN EXTRACT(YEAR FROM order_date) < 2024 THEN 1 ELSE 0 END) as is_pre_2024_customer,
--         COUNT(DISTINCT order_id) as order_count_2024,
--         SUM(order_total) as total_revenue_2024
--     FROM business_intelligence.canonical_integrated_orders
--     WHERE EXTRACT(YEAR FROM order_date) = 2024
--     AND hubspot_id IS NOT NULL
--     AND sales_name IS NOT NULL
--     AND sales_name != ''
--     --AND sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
--     GROUP BY hubspot_id
-- ),

-- customer_segment_analysis AS (
--     -- Existing pre-2024: Customers who placed orders in 2024 but signed up before 2024
--     SELECT 
--         'Existing (Pre-2024)' as segment,
--         '2024' as year,
--         COUNT(DISTINCT hubspot_id) as customer_count,
--         SUM(total_revenue_2024) as total_revenue,
--         COUNT(DISTINCT CASE WHEN order_count_2024 > 1 THEN hubspot_id END) as repeat_customers,
--         COUNT(DISTINCT CASE WHEN order_count_2024 = 1 THEN hubspot_id END) as one_time_customers
--     FROM customer_segment_2024
--     WHERE is_pre_2024_customer = 1
    
--     UNION ALL
    
--     -- One-timer 2024: Customers who placed exactly one order in 2024
--     SELECT 
--         'One-Timer (2024)' as segment,
--         '2024' as year,
--         COUNT(DISTINCT hubspot_id) as customer_count,
--         SUM(total_revenue_2024) as total_revenue,
--         0 as repeat_customers,
--         COUNT(DISTINCT hubspot_id) as one_time_customers
--     FROM customer_segment_2024
--     WHERE is_pre_2024_customer = 0 
--     AND order_count_2024 = 1
    
--     UNION ALL
    
--     -- Repeat 2024: Customers who placed multiple orders in 2024
--     SELECT 
--         'Repeat (2024)' as segment,
--         '2024' as year,
--         COUNT(DISTINCT hubspot_id) as customer_count,
--         SUM(total_revenue_2024) as total_revenue,
--         COUNT(DISTINCT hubspot_id) as repeat_customers,
--         0 as one_time_customers
--     FROM customer_segment_2024
--     WHERE is_pre_2024_customer = 0 
--     AND order_count_2024 > 1
-- )

-- -- Create a view for customer segment analysis
-- CREATE OR REPLACE VIEW customer_segment_analysis AS 
-- SELECT * FROM (
--     -- Existing pre-2024: Customers who placed orders in 2024 but signed up before 2024
--     SELECT 
--         'Existing (Pre-2024)' as segment,
--         '2024' as year,
--         COUNT(DISTINCT customer_id) as customer_count,
--         SUM(total_revenue_2024) as total_revenue,
--         COUNT(DISTINCT CASE WHEN order_count_2024 > 1 THEN customer_id END) as repeat_customers,
--         COUNT(DISTINCT CASE WHEN order_count_2024 = 1 THEN customer_id END) as one_time_customers
--     FROM customer_segment_2024
--     WHERE is_pre_2024_customer = 1
    
--     UNION ALL
    
--     -- One-timer 2024: Customers who placed exactly one order in 2024
--     SELECT 
--         'One-Timer (2024)' as segment,
--         '2024' as year,
--         COUNT(DISTINCT customer_id) as customer_count,
--         SUM(total_revenue_2024) as total_revenue,
--         0 as repeat_customers,
--         COUNT(DISTINCT customer_id) as one_time_customers
--     FROM customer_segment_2024
--     WHERE is_pre_2024_customer = 0 
--     AND order_count_2024 = 1
    
--     UNION ALL
    
--     -- Repeat 2024: Customers who placed multiple orders in 2024
--     SELECT 
--         'Repeat (2024)' as segment,
--         '2024' as year,
--         COUNT(DISTINCT customer_id) as customer_count,
--         SUM(total_revenue_2024) as total_revenue,
--         COUNT(DISTINCT customer_id) as repeat_customers,
--         0 as one_time_customers
--     FROM customer_segment_2024
--     WHERE is_pre_2024_customer = 0 
--     AND order_count_2024 > 1
-- ) t

-- -- Main query continues
-- SELECT 
--     ac.rsm_name,
-- SELECT 
--     ac.rsm_name,
--     multiIf(
--         fo.contact_id IS NULL, 'Existing (Pre-2025)',
--         rc.contact_id IS NOT NULL, 'Repeat (2025)',
--         'One-Timer (2025)'
--     ) as customer_segment,
--     multiIf(
--         sc.contact_id IS NOT NULL, 'With Support',
--         'No Support'
--     ) as support_status,
--     COUNT(DISTINCT ac.contact_id) as customers,
--     COUNT(DISTINCT io.sample_id) as orders,
--     SUM(COALESCE(cm.calls, 0)) as calls,
--     SUM(COALESCE(cm.meetings, 0)) as meetings,
--     ROUND(SUM(io.total), 2) as revenue,
--     ROUND(SUM(io.total) / COUNT(DISTINCT io.sample_id), 2) as aov
-- FROM all_2025_customers ac
-- LEFT JOIN first_orders_2025 fo ON toString(fo.contact_id) = ac.contact_id
-- LEFT JOIN repeat_customers rc ON toString(rc.contact_id) = ac.contact_id
-- LEFT JOIN supported_customers sc ON toString(sc.contact_id) = ac.contact_id
-- LEFT JOIN calls_meetings_data cm ON toString(cm.contact_id) = ac.contact_id
-- INNER JOIN business_intelligence.canonical_integrated_orders io 
--     ON toString(io.hubspot_id) = ac.contact_id
-- WHERE EXTRACT(YEAR FROM io.order_date) = 2025
-- GROUP BY ac.rsm_name, customer_segment, support_status
-- ORDER BY ac.rsm_name, customer_segment, support_status DESC


-- ============================================================================
-- RSM Performance Report - 2025
-- Fixed version that handles Sales Director reassignments
-- ============================================================================
-- 
-- ISSUE FIXED: When RSMs left the company, their customers were temporarily
-- reassigned to Sales Directors (Suzi Hansen, Malek Bishawi, Kristina Banister),
-- then later reassigned to new RSMs. This caused duplicate customer counting.
--
-- SOLUTION: Prioritize actual RSM assignments over Sales Directors
-- ============================================================================
-- ============================================================================
-- RSM Performance Report - 2025 (FINAL CORRECTED VERSION)
-- ============================================================================
-- Uses customer_id (not hubspot_id) to match YoY query exactly
-- Fixes: SD duplication + correct customer counting
-- ============================================================================

WITH 
-- Calculate first order year from actual orders using CUSTOMER_ID
first_order_year_calculated AS (
    SELECT 
        customer_id,
        MIN(toYear(order_date)) as first_order_year
    FROM business_intelligence.canonical_integrated_orders
    GROUP BY customer_id
),
-- Identify new customers in 2025
new_customers_2025 AS (
    SELECT customer_id
    FROM first_order_year_calculated
    WHERE first_order_year = 2025
),
-- Count orders per customer in 2025
customer_order_count_2025 AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT sample_id) as order_count_2025
    FROM business_intelligence.canonical_integrated_orders
    WHERE toYear(order_date) = 2025
    GROUP BY customer_id
),
-- Map customer_id to hubspot_id for journey data
customer_to_hubspot AS (
    SELECT 
        customer_id,
        argMax(toString(hubspot_id), order_date) as contact_id
    FROM business_intelligence.canonical_integrated_orders
    WHERE hubspot_id IS NOT NULL
    GROUP BY customer_id
),
-- Sales/Clinical support tracking
supported_customers AS (
    SELECT DISTINCT contact_id
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_category IN ('Sales Activity', 'Clinical Activity')
),
-- Calls and meetings data
calls_meetings_data AS (
    SELECT 
        contact_id,
        countIf(touchpoint_type = 'Call') as calls,
        countIf(touchpoint_type = 'Meeting') as meetings
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_type IN ('Call', 'Meeting')
    AND EXTRACT(YEAR FROM touchpoint_date) = 2025
    GROUP BY contact_id
),
-- Smart RSM assignment using CUSTOMER_ID
customer_rsm_assignment AS (
    SELECT 
        customer_id,
        argMaxIf(
            sales_name, 
            order_date, 
            sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
        ) as actual_rsm,
        argMaxIf(
            sales_name, 
            order_date, 
            sales_name IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
        ) as sales_director,
        argMax(state, order_date) as state
    FROM business_intelligence.canonical_integrated_orders
    WHERE EXTRACT(YEAR FROM order_date) = 2025
        AND sales_name IS NOT NULL
        AND sales_name != ''
    GROUP BY customer_id
),
final_assignment AS (
    SELECT 
        customer_id,
        COALESCE(actual_rsm, sales_director) as rsm_name,
        state,
        CASE WHEN actual_rsm IS NULL THEN 1 ELSE 0 END as is_sd_only
    FROM customer_rsm_assignment
)
-- Main query
SELECT 
    ac.rsm_name,
    multiIf(
        nc.customer_id IS NOT NULL AND oc.order_count_2025 = 1, 'One-Timer (2025)',
        nc.customer_id IS NOT NULL AND oc.order_count_2025 > 1, 'Repeat (2025)',
        'Existing (Pre-2025)'
    ) as customer_segment,
    multiIf(
        sc.contact_id IS NOT NULL, 'With Support',
        'No Support'
    ) as support_status,
    COUNT(DISTINCT ac.customer_id) as customers,
    COUNT(DISTINCT io.sample_id) as orders,
    SUM(COALESCE(cm.calls, 0)) as calls,
    SUM(COALESCE(cm.meetings, 0)) as meetings,
    ROUND(SUM(io.total), 2) as revenue,
    ROUND(SUM(io.total) / COUNT(DISTINCT io.sample_id), 2) as aov,
    SUM(ac.is_sd_only) as customers_needing_rsm_assignment
FROM final_assignment ac
LEFT JOIN new_customers_2025 nc ON nc.customer_id = ac.customer_id
LEFT JOIN customer_order_count_2025 oc ON oc.customer_id = ac.customer_id
LEFT JOIN customer_to_hubspot ch ON ch.customer_id = ac.customer_id
LEFT JOIN supported_customers sc ON sc.contact_id = ch.contact_id
LEFT JOIN calls_meetings_data cm ON cm.contact_id = ch.contact_id
INNER JOIN business_intelligence.canonical_integrated_orders io 
    ON io.customer_id = ac.customer_id
WHERE EXTRACT(YEAR FROM io.order_date) = 2025
GROUP BY ac.rsm_name, customer_segment, support_status
ORDER BY ac.rsm_name, customer_segment, support_status DESC;