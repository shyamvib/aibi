WITH engaged_contacts AS (
    -- Contacts who had calls or meetings in 2025
    SELECT DISTINCT contact_id
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_category IN ('Sales Activity', 'Clinical Activity')
    AND touchpoint_type IN ('Call', 'Meeting')
    AND EXTRACT(YEAR FROM touchpoint_date) = 2025
),
contacts_with_orders AS (
    -- Contacts who ever placed an order (any year)
    SELECT DISTINCT contact_id
    FROM business_intelligence.customer_journey_final
    WHERE touchpoint_type IN ('First Order', 'Repeat Order')
),
proper_new_leads_2025 AS (
    -- CRITICAL: Only leads whose FIRST touchpoint is Traffic/Form in 2025
    -- This excludes existing customers whose first touch was Call/Meeting
    SELECT DISTINCT contact_id
    FROM business_intelligence.customer_journey_final
    WHERE is_first_touchpoint = 1
    AND touchpoint_type IN ('TRAFFIC_SOURCE', 'FORM_SUBMISSION')
    AND EXTRACT(YEAR FROM touchpoint_date) = 2025
)
SELECT 
    -- Time
    EXTRACT(YEAR FROM touchpoint_date) as year,
    EXTRACT(MONTH FROM touchpoint_date) as month_number,
    CASE EXTRACT(MONTH FROM touchpoint_date)
        WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April' WHEN 5 THEN 'May' WHEN 6 THEN 'June'
        WHEN 7 THEN 'July' WHEN 8 THEN 'August' WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END as month_name,
    formatDateTime(toStartOfMonth(touchpoint_date), '%Y-%m') as month_label,
    toStartOfMonth(touchpoint_date) as month_date,
    -- RSM
    COALESCE(cjf.rsm_name, cjf.cam_name, cjf.clinical_name) as rsm_name,
    -- Team Type
    CASE 
        WHEN cjf.is_clinical_team = 1 THEN 'Clinical'
        ELSE 'Sales'
    END as team_type,
    -- Metrics
    COUNT(DISTINCT pnl.contact_id) as new_leads_engaged_no_order,
    COUNT(DISTINCT CASE WHEN touchpoint_type = 'Call' THEN concat(toString(pnl.contact_id), '-', toString(touchpoint_date)) END) as calls,
    COUNT(DISTINCT CASE WHEN touchpoint_type = 'Meeting' THEN concat(toString(pnl.contact_id), '-', toString(touchpoint_date)) END) as meetings,
    COUNT(DISTINCT CASE WHEN touchpoint_type IN ('Call', 'Meeting') THEN concat(toString(pnl.contact_id), '-', toString(touchpoint_date)) END) as total_touchpoints
FROM business_intelligence.customer_journey_final cjf
INNER JOIN engaged_contacts ec ON cjf.contact_id = ec.contact_id
INNER JOIN proper_new_leads_2025 pnl ON cjf.contact_id = pnl.contact_id  -- FILTER: Only true new leads
LEFT JOIN contacts_with_orders cwo ON pnl.contact_id = cwo.contact_id
WHERE cwo.contact_id IS NULL  -- No orders ever
AND EXTRACT(YEAR FROM touchpoint_date) = 2025
AND touchpoint_category IN ('Sales Activity', 'Clinical Activity')
AND touchpoint_type IN ('Call', 'Meeting')
GROUP BY 
    year,
    month_number,
    month_name,
    month_label,
    month_date,
    rsm_name,
    team_type
ORDER BY 
    year,
    month_number,
    rsm_name
