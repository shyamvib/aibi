---
title: RSM Detail View
---


```sql rsm_data
SELECT * FROM rsm_performance_data
```

```sql rsm_summary
SELECT 
    rsm_name,
    SUM(CAST(revenue AS DOUBLE)) as total_revenue,
    SUM(CAST(customers AS INTEGER)) as total_customers
FROM ${rsm_data}
GROUP BY rsm_name
ORDER BY total_revenue DESC
```

<Dropdown name=selected_rsm data={rsm_summary} value=rsm_name>
  <DropdownOption value="ALL" valueLabel="All RSMs"/>
</Dropdown>

```sql rsm_detail
SELECT 
    rsm_name,
    customer_segment,
    support_status,
    CAST(customers AS INTEGER) as customers,
    CAST(orders AS INTEGER) as orders,
    CAST(revenue AS DOUBLE) as revenue,
    CAST(aov AS DOUBLE) as aov,
    CAST(revenue AS DOUBLE) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM ${rsm_data} WHERE rsm_name = '${inputs.selected_rsm.value}') * 100 as revenue_percent,
    CAST(calls AS INTEGER) as calls,
    CAST(meetings AS INTEGER) as meetings,
    ROUND(CAST(calls AS DOUBLE) / NULLIF(CAST(customers AS INTEGER), 0), 1) as avg_calls_per_customer,
    ROUND(CAST(meetings AS DOUBLE) / NULLIF(CAST(customers AS INTEGER), 0), 1) as avg_meetings_per_customer
FROM ${rsm_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
ORDER BY customer_segment, support_status DESC
```

## {inputs.selected_rsm.label} - Performance Breakdown

<Tabs defaultValue="overview">
<Tab id="overview" label="Overview">

<BigValue
  data={rsm_summary.filter(d => d.rsm_name === inputs.selected_rsm.value)}
  value=total_revenue
  title="Total Revenue"
  format="$,.2f"
/>

<BigValue
  data={rsm_summary.filter(d => d.rsm_name === inputs.selected_rsm.value)}
  value=total_customers
  title="Total Customers"
  format=","
/>

<BigValue
  data={rsm_metrics}
  value=existing_revenue
  title="Existing Revenue"
  format="$,.2f"
/>

<BigValue
  data={rsm_metrics}
  value=one_timer_revenue
  title="One-Timer Revenue"
  format="$,.2f"
/>

<BigValue
  data={rsm_metrics}
  value=repeat_revenue
  title="Repeat Revenue"
  format="$,.2f"
/>

<BigValue
  data={rsm_metrics}
  value=existing_revenue_percent
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={rsm_metrics}
  value=one_timer_revenue_percent
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={rsm_metrics}
  value=repeat_revenue_percent
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={rsm_metrics}
  value=unsupported_customers
  title="Unsupported Customers"
  format=","
/>

<BigValue
  data={rsm_metrics}
  value=unsupported_percent
  title="% of Total"
  format=".1f%"
/>

<BigValue
  data={rsm_metrics}
  value=retention_rate
  title="Retention Rate"
  format=".1f%"
/>

<BigValue
  data={rsm_metrics}
  value=new_customers_total
  title="New Customers"
  format=","
/>


### Lead Engagement Summary

<BigValue
  data={rsm_leads_summary}
  value=total_leads
  title="Total Leads Engaged (No Orders)"
  format=","
/>

<BigValue
  data={rsm_leads_summary}
  value=total_calls
  title="Total Calls to Leads"
  format=","
/>

<BigValue
  data={rsm_leads_summary}
  value=total_meetings
  title="Total Meetings with Leads"
  format=","
/>

<BigValue
  data={rsm_leads_summary}
  value=avg_calls_per_lead
  title="Avg Calls per Lead"
  format=".1f"
/>

<BigValue
  data={rsm_leads_summary}
  value=avg_meetings_per_lead
  title="Avg Meetings per Lead"
  format=".1f"
/>

<!-- ### Lead Conversion Metrics

<BigValue
  data={lead_conversion_metrics}
  value=lead_to_customer_rate
  title="Lead to Customer Rate"
  format=".1f%"
/>

<BigValue
  data={lead_conversion_metrics}
  value=lead_to_supported_customer_rate
  title="Lead to Supported Customer Rate"
  format=".1f%"
/>

<BigValue
  data={lead_conversion_metrics}
  value=lead_to_customer_engagement_ratio
  title="Lead:Customer Engagement Ratio"
  format=".1f:1"
/> -->

```sql rsm_detail_with_averages
SELECT 
    customer_segment,
    support_status,
    customers,
    orders,
    calls,
    meetings,
    revenue,
    aov,
    revenue_percent,
    ROUND(calls / NULLIF(customers, 0), 1) as avg_calls_per_customer,
    ROUND(meetings / NULLIF(customers, 0), 1) as avg_meetings_per_customer
FROM ${rsm_detail}
```

### Customer Composition

<DataTable
  data={rsm_detail_with_averages}
  columns={[
    {id: "customer_segment", header: "Segment"},
    {id: "support_status", header: "Support"},
    {id: "customers", header: "Customers", format: ","},
    {id: "orders", header: "Orders", format: ","},
    {id: "calls", header: "Calls", format: ","},
    {id: "meetings", header: "Meetings", format: ","},
    {id: "revenue", header: "Revenue", format: "$,.0f"},
    {id: "aov", header: "AOV", format: "$,.0f"},
    {id: "revenue_percent", header: "% Revenue", format: ".1f%"},
    {id: "avg_calls_per_customer", header: "Avg Calls/Customer", format: ".1f"},
    {id: "avg_meetings_per_customer", header: "Avg Meetings/Customer", format: ".1f"}
  ]}
/>

```sql heatmap_data
WITH base_data AS (
    SELECT 
        customer_segment,
        support_status,
        CAST(revenue AS DOUBLE) as revenue
    FROM ${rsm_detail}
),
row_totals AS (
    SELECT 
        customer_segment,
        'Total' as support_status,
        SUM(revenue) as revenue
    FROM base_data
    GROUP BY customer_segment
),
column_totals AS (
    SELECT 
        'Total' as customer_segment,
        support_status,
        SUM(revenue) as revenue
    FROM base_data
    GROUP BY support_status
),
grand_total AS (
    SELECT 
        'Total' as customer_segment,
        'Total' as support_status,
        SUM(revenue) as revenue
    FROM base_data
),
combined_data AS (
    SELECT customer_segment, support_status, revenue FROM base_data
    UNION ALL
    SELECT customer_segment, support_status, revenue FROM row_totals
    UNION ALL
    SELECT customer_segment, support_status, revenue FROM column_totals
    UNION ALL
    SELECT customer_segment, support_status, revenue FROM grand_total
)
SELECT 
    customer_segment,
    support_status,
    revenue
FROM combined_data
ORDER BY 
    customer_segment != 'Total',
    customer_segment,
    support_status != 'Total',
    support_status
```

<Heatmap
  data={heatmap_data}
  x=customer_segment
  y=support_status
  value=revenue
  title="Revenue by Segment and Support Status"
  valueFormat="$,.0f"
/>

```sql heatmap_percentage
WITH base_data AS (
    SELECT 
        customer_segment,
        support_status,
        CAST(revenue AS DOUBLE) as revenue
    FROM ${rsm_detail}
),
total_revenue AS (
    SELECT SUM(revenue) as total_revenue FROM base_data
),
row_totals AS (
    SELECT 
        customer_segment,
        'Total' as support_status,
        SUM(revenue) as revenue
    FROM base_data
    GROUP BY customer_segment
),
column_totals AS (
    SELECT 
        'Total' as customer_segment,
        support_status,
        SUM(revenue) as revenue
    FROM base_data
    GROUP BY support_status
),
grand_total AS (
    SELECT 
        'Total' as customer_segment,
        'Total' as support_status,
        SUM(revenue) as revenue
    FROM base_data
),
combined_data AS (
    SELECT customer_segment, support_status, revenue FROM base_data
    UNION ALL
    SELECT customer_segment, support_status, revenue FROM row_totals
    UNION ALL
    SELECT customer_segment, support_status, revenue FROM column_totals
    UNION ALL
    SELECT customer_segment, support_status, revenue FROM grand_total
)
SELECT 
    customer_segment,
    support_status,
    revenue,
    (revenue / (SELECT total_revenue FROM total_revenue)) * 100 as percentage
FROM combined_data
ORDER BY 
    customer_segment != 'Total',
    customer_segment,
    support_status != 'Total',
    support_status
```

<Heatmap
  data={heatmap_percentage}
  x=customer_segment
  y=support_status
  value=percentage
  title="Revenue Percentage by Segment and Support Status"
  valueFormat=".1f%"
/>

</Tab>

<Tab id="monthly_trends" label="Monthly Trends">

```sql rsm_metrics
WITH segment_totals AS (
    SELECT 
        rsm_name,
        customer_segment,
        SUM(CAST(customers AS INTEGER)) as segment_customers,
        SUM(CAST(revenue AS DOUBLE)) as segment_revenue
    FROM ${rsm_data}
    WHERE rsm_name = '${inputs.selected_rsm.value}'
    GROUP BY rsm_name, customer_segment
),
new_customers AS (
    SELECT 
        rsm_name,
        SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END) as new_customers,
        SUM(CASE WHEN customer_segment = 'Repeat (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as repeat_customers,
        SUM(CASE WHEN customer_segment = 'One-Timer (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as one_time_customers
    FROM ${rsm_data}
    WHERE rsm_name = '${inputs.selected_rsm.value}'
    GROUP BY rsm_name
),
support_totals AS (
    SELECT 
        rsm_name,
        support_status,
        SUM(CAST(customers AS INTEGER)) as support_customers
    FROM ${rsm_data}
    WHERE rsm_name = '${inputs.selected_rsm.value}'
    GROUP BY rsm_name, support_status
)
SELECT 
    r.rsm_name,
    
    -- Existing metrics
    MAX(CASE WHEN st.customer_segment = 'Existing (Pre-2025)' THEN st.segment_revenue ELSE 0 END) as existing_revenue,
    MAX(CASE WHEN st.customer_segment = 'Existing (Pre-2025)' THEN st.segment_customers ELSE 0 END) as existing_customers,
    MAX(CASE WHEN st.customer_segment = 'Existing (Pre-2025)' THEN st.segment_revenue ELSE 0 END) / SUM(CAST(r.revenue AS DOUBLE)) * 100 as existing_revenue_percent,
    
    -- Repeat metrics
    MAX(CASE WHEN st.customer_segment = 'Repeat (2025)' THEN st.segment_revenue ELSE 0 END) as repeat_revenue,
    MAX(CASE WHEN st.customer_segment = 'Repeat (2025)' THEN st.segment_customers ELSE 0 END) as repeat_customers,
    MAX(CASE WHEN st.customer_segment = 'Repeat (2025)' THEN st.segment_revenue ELSE 0 END) / SUM(CAST(r.revenue AS DOUBLE)) * 100 as repeat_revenue_percent,
    
    -- One-timer metrics
    MAX(CASE WHEN st.customer_segment = 'One-Timer (2025)' THEN st.segment_revenue ELSE 0 END) as one_timer_revenue,
    MAX(CASE WHEN st.customer_segment = 'One-Timer (2025)' THEN st.segment_customers ELSE 0 END) as one_timer_customers,
    MAX(CASE WHEN st.customer_segment = 'One-Timer (2025)' THEN st.segment_revenue ELSE 0 END) / SUM(CAST(r.revenue AS DOUBLE)) * 100 as one_timer_revenue_percent,
    
    -- Support metrics
    MAX(CASE WHEN sup.support_status = 'No Support' THEN sup.support_customers ELSE 0 END) as unsupported_customers,
    MAX(CASE WHEN sup.support_status = 'No Support' THEN sup.support_customers ELSE 0 END) / SUM(CAST(r.customers AS INTEGER)) * 100 as unsupported_percent,
    
    -- Retention rate
    MAX(nc.repeat_customers) * 100.0 / NULLIF(MAX(nc.repeat_customers) + MAX(nc.one_time_customers), 0) as retention_rate,
    MAX(nc.repeat_customers) + MAX(nc.one_time_customers) as new_customers_total
FROM ${rsm_data} r
JOIN segment_totals st ON r.rsm_name = st.rsm_name
JOIN new_customers nc ON r.rsm_name = nc.rsm_name
JOIN support_totals sup ON r.rsm_name = sup.rsm_name
WHERE r.rsm_name = '${inputs.selected_rsm.value}'
GROUP BY r.rsm_name
```



## Monthly Performance Trend

```sql rsm_monthly_data
SELECT * FROM rsm_monthly_performance
```



```sql monthly_trend
SELECT 
    year,
    month_number,
    month_label,
    month_date,
    rsm_name,
    SUM(CAST(revenue AS DOUBLE)) as monthly_revenue,
    SUM(CAST(orders AS INTEGER)) as monthly_orders,
    SUM(CAST(active_customers_this_month AS INTEGER)) as monthly_customers,
    SUM(CAST(total_calls AS INTEGER)) as monthly_calls,
    SUM(CAST(total_meetings AS INTEGER)) as monthly_meetings
FROM ${rsm_monthly_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
GROUP BY year, month_number, month_label, month_date, rsm_name
ORDER BY month_date
```

<LineChart
  data={monthly_trend}
  x="month_label"
  y="monthly_revenue"
  y_fmt="usd"
  yAxisTitle="Revenue"
  title="Monthly Revenue Trend"
  formatY="$,.0f"
  xSort="asc"
/>

```sql leads_engagement_data
SELECT * FROM leads_engagement
WHERE rsm_name = '${inputs.selected_rsm.value}'
LIMIT 100
```

```sql rsm_leads_summary
SELECT 
    SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as total_leads,
    SUM(CAST(calls AS INTEGER)) as total_calls,
    SUM(CAST(meetings AS INTEGER)) as total_meetings,
    ROUND(SUM(CAST(calls AS DOUBLE)) / NULLIF(SUM(CAST(new_leads_engaged_no_order AS DOUBLE)), 0), 1) as avg_calls_per_lead,
    ROUND(SUM(CAST(meetings AS DOUBLE)) / NULLIF(SUM(CAST(new_leads_engaged_no_order AS DOUBLE)), 0), 1) as avg_meetings_per_lead
FROM leads_engagement
WHERE rsm_name = '${inputs.selected_rsm.value}'
```

```sql lead_conversion_metrics
WITH lead_data AS (
    SELECT 
        SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as total_leads,
        SUM(CAST(calls AS INTEGER)) as total_lead_calls,
        SUM(CAST(meetings AS INTEGER)) as total_lead_meetings
    FROM leads_engagement
    WHERE rsm_name = '${inputs.selected_rsm.value}'
),
new_customers_data AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN 1 END) as new_customers_2025,
        COUNT(DISTINCT CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') AND support_status = 'With Support' THEN 1 END) as new_customers_with_support,
        SUM(CAST(total_calls AS INTEGER)) as total_customer_calls,
        SUM(CAST(total_meetings AS INTEGER)) as total_customer_meetings
    FROM rsm_monthly_performance
    WHERE rsm_name = '${inputs.selected_rsm.value}'
)
SELECT
    ld.total_leads,
    cd.new_customers_2025,
    cd.new_customers_with_support,
    ROUND(cd.new_customers_2025 / NULLIF(cd.new_customers_2025 + ld.total_leads, 0) * 100, 1) as lead_to_customer_rate,
    ROUND(cd.new_customers_with_support / NULLIF(cd.new_customers_2025 + ld.total_leads, 0) * 100, 1) as lead_to_supported_customer_rate,
    ld.total_lead_calls + ld.total_lead_meetings as total_lead_touchpoints,
    cd.total_customer_calls + cd.total_customer_meetings as total_customer_touchpoints,
    ROUND((ld.total_lead_calls + ld.total_lead_meetings) / NULLIF(ld.total_leads, 0), 1) as touchpoints_per_lead,
    ROUND((cd.total_customer_calls + cd.total_customer_meetings) / NULLIF(cd.new_customers_2025, 0), 1) as touchpoints_per_customer,
    ROUND((ld.total_lead_calls + ld.total_lead_meetings) / NULLIF(cd.total_customer_calls + cd.total_customer_meetings, 0), 1) as lead_to_customer_engagement_ratio
FROM lead_data ld, new_customers_data cd
```

```sql monthly_lead_data
SELECT 
    month_label,
    month_date,
    SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as leads,
    SUM(CAST(calls AS INTEGER)) as calls,
    SUM(CAST(meetings AS INTEGER)) as meetings
FROM leads_engagement
WHERE rsm_name = '${inputs.selected_rsm.value}'
GROUP BY month_label, month_date
ORDER BY month_date
```

```sql orders_customers_trend
SELECT 
    month_label,
    month_date,
    'Orders' as metric,
    monthly_orders as value
FROM ${monthly_trend}
UNION ALL
SELECT 
    month_label,
    month_date,
    'Customers' as metric,
    monthly_customers as value
FROM ${monthly_trend}
UNION ALL
SELECT 
    month_label,
    month_date,
    'Leads' as metric,
    leads as value
FROM ${monthly_lead_data}
ORDER BY month_date
```

<LineChart
  data={orders_customers_trend}
  x="month_label"
  y="value"
  series="metric"
  yAxisTitle="Count"
  title="Monthly Orders, Customers, and Leads"
  xSort="month_date"
/>

```sql lead_calls_meetings_trend
SELECT 
    month_label,
    month_date,
    'Lead Calls' as metric,
    calls as value
FROM ${monthly_lead_data}
UNION ALL
SELECT 
    month_label,
    month_date,
    'Lead Meetings' as metric,
    meetings as value
FROM ${monthly_lead_data}
ORDER BY month_date
```

<LineChart
  data={lead_calls_meetings_trend}
  x="month_label"
  y="value"
  series="metric"
  yAxisTitle="Count"
  title="Monthly Lead Calls & Meetings"
  xSort="month_date"
/>

```sql monthly_engagement_comparison
WITH lead_monthly AS (
    SELECT 
        month_label,
        month_date,
        SUM(CAST(calls AS INTEGER) + CAST(meetings AS INTEGER)) as lead_touchpoints,
        SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as leads
    FROM leads_engagement
    WHERE rsm_name = '${inputs.selected_rsm.value}'
    GROUP BY month_label, month_date
),
customer_monthly AS (
    SELECT 
        month_label,
        month_date,
        SUM(CAST(total_calls AS INTEGER) + CAST(total_meetings AS INTEGER)) as customer_touchpoints,
        SUM(CAST(active_customers_this_month AS INTEGER)) as customers
    FROM ${monthly_trend}
    GROUP BY month_label, month_date
)
SELECT
    lm.month_label,
    lm.month_date,
    lm.lead_touchpoints,
    lm.leads,
    cm.customer_touchpoints,
    cm.customers,
    ROUND(lm.lead_touchpoints / NULLIF(lm.leads, 0), 1) as touchpoints_per_lead,
    ROUND(cm.customer_touchpoints / NULLIF(cm.customers, 0), 1) as touchpoints_per_customer,
    ROUND(lm.lead_touchpoints / NULLIF(cm.customer_touchpoints, 0), 1) as lead_to_customer_ratio
FROM lead_monthly lm
LEFT JOIN customer_monthly cm ON lm.month_date = cm.month_date
ORDER BY lm.month_date
```

```sql engagement_ratio_trend
SELECT 
    month_label,
    month_date,
    'Touchpoints per Lead' as metric,
    touchpoints_per_lead as value
FROM ${monthly_engagement_comparison}
UNION ALL
SELECT 
    month_label,
    month_date,
    'Touchpoints per Customer' as metric,
    touchpoints_per_customer as value
FROM ${monthly_engagement_comparison}
ORDER BY month_date
```

<!-- <LineChart
  data={engagement_ratio_trend}
  x="month_label"
  y="value"
  series="metric"
  yAxisTitle="Touchpoints"
  title="Monthly Engagement Efficiency: Leads vs Customers"
  xSort="month_date"
/> -->

```sql ratio_trend
SELECT 
    month_label,
    month_date,
    lead_to_customer_ratio as value
FROM ${monthly_engagement_comparison}
ORDER BY month_date
```

<!-- <LineChart
  data={ratio_trend}
  x="month_label"
  y="value"
  yAxisTitle="Ratio"
  title="Monthly Lead:Customer Engagement Ratio (>1 means more time on leads)"
  xSort="month_date"
/> -->

```sql calls_meetings_trend
SELECT 
    month_label,
    month_date,
    'Calls' as metric,
    monthly_calls as value
FROM ${monthly_trend}
UNION ALL
SELECT 
    month_label,
    month_date,
    'Meetings' as metric,
    monthly_meetings as value
FROM ${monthly_trend}
ORDER BY month_date
```

<LineChart
  data={calls_meetings_trend}
  x="month_label"
  y="value"
  series="metric"
  yAxisTitle="Count"
  title="Monthly Calls and Meetings"
  xSort="month_date"
/>

<ButtonGroup name="support_filter">
  <ButtonGroupItem value="With Support" valueLabel="With Support" />
  <ButtonGroupItem value="No Support" valueLabel="No Support" />
</ButtonGroup>

```sql monthly_segment_trend
SELECT 
    year,
    month_label,
    month_date,
    rsm_name,
    customer_segment,
    support_status,
    SUM(CAST(revenue AS DOUBLE)) as segment_revenue
FROM ${rsm_monthly_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.support_filter}' OR '${inputs.support_filter}' = 'All')
GROUP BY year, month_label, month_date, rsm_name, customer_segment, support_status
ORDER BY month_date
```

<LineChart
  data={monthly_segment_trend}
  x="month_label"
  y="segment_revenue"
  series="customer_segment"
  yAxisTitle="Revenue"
  title="Monthly Revenue by Customer Segment (${inputs.support_filter === 'All' ? 'All Support Status' : inputs.support_filter})"
  formatY="$,.0f"
  xSort="month_date"
/>

</Tab>

<Tab id="customer_profile" label="Customer Profile">

## Customer Profile Analysis

```sql customer_profile_data
SELECT * FROM customer_profile
```

```sql top_credential
SELECT 
    credential as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY credential
ORDER BY value DESC
LIMIT 1
```

```sql top_state
SELECT 
    state as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY state
ORDER BY value DESC
LIMIT 1
```

```sql top_years
SELECT 
    years_in_practice as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY years_in_practice
ORDER BY value DESC
LIMIT 1
```

```sql top_referral
SELECT 
    referral_source as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY referral_source
ORDER BY value DESC
LIMIT 1
```

```sql top_tests_interested
SELECT 
    tests_interested_in as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY tests_interested_in
ORDER BY value DESC
LIMIT 1
```

```sql top_competitors
SELECT 
    competitors_used as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY competitors_used
ORDER BY value DESC
LIMIT 1
```

```sql top_samples
SELECT 
    samples_per_week as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY samples_per_week
ORDER BY value DESC
LIMIT 1
```

```sql top_source
SELECT 
    hs_latest_source as name,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM customer_profile 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
        AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM customer_profile
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY hs_latest_source
ORDER BY value DESC
LIMIT 1
```

<BigValue
  data={top_credential}
  value=name
  title="Top Credential"
/>

<BigValue
  data={top_credential}
  value=value
  title="Revenue"
  format="$,.0f"
/>

<BigValue
  data={top_credential}
  value=percentage
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={top_state}
  value=name
  title="Top State"
/>

<BigValue
  data={top_state}
  value=value
  title="Revenue"
  format="$,.0f"
/>

<BigValue
  data={top_state}
  value=percentage
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={top_source}
  value=name
  title="Top Latest Source"
/>

<BigValue
  data={top_source}
  value=value
  title="Revenue"
  format="$,.0f"
/>

<BigValue
  data={top_source}
  value=percentage
  title="% of Total Revenue"
  format=".1f%"
/>

### Support Status Filter
<ButtonGroup name="profile_support_filter" valueLabel="Support Status">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All</ButtonGroupItem>
  <ButtonGroupItem value="With Support" valueLabel="With Support">With Support</ButtonGroupItem>
  <ButtonGroupItem value="No Support" valueLabel="No Support">No Support</ButtonGroupItem>
</ButtonGroup>

### Customer Segment Filter
<ButtonGroup name="profile_segment_filter" valueLabel="Customer Segment">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All</ButtonGroupItem>
  <ButtonGroupItem value="Existing (Pre-2025)" valueLabel="Existing">Existing</ButtonGroupItem>
  <ButtonGroupItem value="Repeat (2025)" valueLabel="Repeat">Repeat</ButtonGroupItem>
  <ButtonGroupItem value="One-Timer (2025)" valueLabel="One-Timer">One-Timer</ButtonGroupItem>
</ButtonGroup>

### Credentials Distribution

```sql credential_distribution
SELECT 
    credential as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY credential
ORDER BY value DESC
LIMIT 10
```

```sql pie_sql
SELECT name, value, customers
FROM ${credential_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Credential (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### State Distribution

```sql state_distribution
SELECT 
    state as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY state
ORDER BY value DESC
LIMIT 10
```

```sql state_pie_sql
SELECT name, value, customers
FROM ${state_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...state_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by State (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### Years in Practice Distribution

```sql years_distribution
SELECT 
    years_in_practice as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY years_in_practice
ORDER BY 
    CASE 
        WHEN name = '0-4 years' THEN 1
        WHEN name = '5-9 years' THEN 2
        WHEN name = '10-14 years' THEN 3
        WHEN name = '15-19 years' THEN 4
        WHEN name = '20+ years' THEN 5
        ELSE 6
    END
```

```sql years_pie_sql
SELECT name, value, customers
FROM ${years_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...years_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Years in Practice (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### Referral Source Distribution

```sql referral_distribution
SELECT 
    referral_source as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY referral_source
ORDER BY value DESC
LIMIT 10
```

```sql referral_pie_sql
SELECT name, value, customers
FROM ${referral_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...referral_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Referral Source (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### Tests Interested In

```sql tests_interested_distribution
SELECT 
    tests_interested_in as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY tests_interested_in
ORDER BY value DESC
LIMIT 10
```

```sql tests_interested_pie_sql
SELECT name, value, customers
FROM ${tests_interested_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...tests_interested_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Tests Interested In (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### Competitors Used

```sql competitors_distribution
SELECT 
    competitors_used as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY competitors_used
ORDER BY value DESC
LIMIT 10
```

```sql competitors_pie_sql
SELECT name, value, customers
FROM ${competitors_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...competitors_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Competitors Used (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### Samples Per Week

```sql samples_distribution
SELECT 
    samples_per_week as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY samples_per_week
ORDER BY 
    CASE 
        WHEN name = '0-10' THEN 1
        WHEN name = '11-20' THEN 2
        WHEN name = '21-50' THEN 3
        WHEN name = '51-100' THEN 4
        WHEN name = '100+' THEN 5
        ELSE 6
    END
```

```sql samples_pie_sql
SELECT name, value, customers
FROM ${samples_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...samples_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Samples Per Week (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

### Latest Source

```sql source_distribution
SELECT 
    hs_latest_source as name,
    SUM(CAST(customer_count AS INTEGER)) as customers,
    ROUND(SUM(CAST(revenue AS DOUBLE)), 0) as value
FROM ${customer_profile_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.profile_support_filter}' OR '${inputs.profile_support_filter}' = 'All')
    AND (customer_segment = '${inputs.profile_segment_filter}' OR '${inputs.profile_segment_filter}' = 'All')
GROUP BY hs_latest_source
ORDER BY value DESC
LIMIT 10
```

```sql source_pie_sql
SELECT name, value, customers
FROM ${source_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Customers: ' + params.data.customers.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...source_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Latest Source (${inputs.profile_support_filter} / ${inputs.profile_segment_filter})`}
/>

</Tab>

<Tab id="product_analysis" label="Product Analysis">

```sql product_data
SELECT * FROM product_analysis
```

```sql top_test_revenue
SELECT 
    test_name as name,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)) / (SELECT SUM(CAST(total_test_value AS DOUBLE)) FROM product_analysis 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
        AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM product_analysis
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY test_name
ORDER BY value DESC
LIMIT 1
```

```sql top_test_orders
SELECT 
    test_name as name,
    SUM(CAST(times_ordered AS INTEGER)) as value,
    ROUND(SUM(CAST(times_ordered AS INTEGER)) / (SELECT SUM(CAST(times_ordered AS INTEGER)) FROM product_analysis 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
        AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM product_analysis
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY test_name
ORDER BY value DESC
LIMIT 1
```

```sql top_bundle
SELECT 
    bundle_name as name,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)) / (SELECT SUM(CAST(total_test_value AS DOUBLE)) FROM product_analysis 
        WHERE rsm_name = '${inputs.selected_rsm.value}'
        AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
        AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM product_analysis
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY bundle_name
ORDER BY value DESC
LIMIT 1
```

<BigValue
  data={top_test_revenue}
  value=name
  title="Top Test by Revenue"
/>

<!-- <BigValue
  data={top_test_revenue}
  value=value
  title="Revenue"
  format="$,.0f"
/> -->

<BigValue
  data={top_test_revenue}
  value=percentage
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={top_test_orders}
  value=name
  title="Top Test by Orders"
/>

<BigValue
  data={top_test_orders}
  value=value
  title="Orders"
  format=","
/>

<BigValue
  data={top_test_orders}
  value=percentage
  title="% of Total Orders"
  format=".1f%"
/>

<BigValue
  data={top_bundle}
  value=name
  title="Top Bundle"
/>

<!-- <BigValue
  data={top_bundle}
  value=value
  title="Revenue"
  format="$,.0f"
/> -->

<BigValue
  data={top_bundle}
  value=percentage
  title="% of Total Revenue"
  format=".1f%"
/>

### Support Status Filter
<ButtonGroup name="product_support_filter" valueLabel="Support Status">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All</ButtonGroupItem>
  <ButtonGroupItem value="With Support" valueLabel="With Support">With Support</ButtonGroupItem>
  <ButtonGroupItem value="No Support" valueLabel="No Support">No Support</ButtonGroupItem>
</ButtonGroup>

### Customer Segment Filter
<ButtonGroup name="product_segment_filter" valueLabel="Customer Segment">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All</ButtonGroupItem>
  <ButtonGroupItem value="Existing (Pre-2025)" valueLabel="Existing">Existing</ButtonGroupItem>
  <ButtonGroupItem value="Repeat (2025)" valueLabel="Repeat">Repeat</ButtonGroupItem>
  <ButtonGroupItem value="One-Timer (2025)" valueLabel="One-Timer">One-Timer</ButtonGroupItem>
</ButtonGroup>

### Top Tests by Revenue

```sql top_tests_by_revenue
SELECT 
    test_name as name,
    SUM(CAST(times_ordered AS INTEGER)) as orders,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value
FROM ${product_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY test_name
ORDER BY value DESC
LIMIT 10
```

```sql tests_pie_sql
SELECT name, value, orders
FROM ${top_tests_by_revenue}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Orders: ' + params.data.orders.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...tests_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Top 10 Tests by Revenue (${inputs.product_support_filter} / ${inputs.product_segment_filter})`}
/>

### Top Tests by Orders

```sql top_tests_by_orders
SELECT 
    test_name as name,
    SUM(CAST(times_ordered AS INTEGER)) as value,
    SUM(CAST(total_test_value AS DOUBLE)) as revenue
FROM ${product_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY test_name
ORDER BY value DESC
LIMIT 10
```

```sql orders_pie_sql
SELECT name, value, revenue
FROM ${top_tests_by_orders}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': ' + params.value.toLocaleString() + ' orders (' + params.percent + '%)' + '<br/>Revenue: $' + params.data.revenue.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...orders_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Top 10 Tests by Order Volume (${inputs.product_support_filter} / ${inputs.product_segment_filter})`}
/>

### Bundle Distribution

```sql bundle_distribution
SELECT 
    bundle_name as name,
    SUM(CAST(times_ordered AS INTEGER)) as orders,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value
FROM ${product_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY bundle_name
ORDER BY value DESC
LIMIT 10
```

```sql bundle_pie_sql
SELECT name, value, orders
FROM ${bundle_distribution}
```

<ECharts config={{
    tooltip: {
        formatter: function(params) {
            return params.name + ': $' + params.value.toLocaleString() + ' (' + params.percent + '%)' + '<br/>Orders: ' + params.data.orders.toLocaleString();
        }
    },
    series: [
        {
            type: 'pie',
            radius: '60%',
            data: [...bundle_pie_sql],
            label: {
                formatter: '{b}'
            }
        }
    ]
}}
  title={`Revenue by Bundle (${inputs.product_support_filter} / ${inputs.product_segment_filter})`}
/>

</Tab>
</Tabs>

## Customer Segment Analysis

```sql customer_segment_pie
SELECT 
    customer_segment as name,
    SUM(CAST(revenue AS DOUBLE)) as value
FROM ${rsm_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
GROUP BY customer_segment
```

<ECharts config={
    {
        title: {
            text: 'Revenue by Customer Segment',
            left: 'center'
        },
        tooltip: {
            formatter: '{b}: ${value} ({d}%)'
        },
        legend: {
            orient: 'vertical',
            left: 'left'
        },
        series: [
        {
          type: 'pie',
          radius: '50%',
          data: [...customer_segment_pie],
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    }
}
/>

```sql support_status_pie
SELECT 
    support_status as name,
    SUM(CAST(revenue AS DOUBLE)) as value
FROM ${rsm_data}
WHERE rsm_name = '${inputs.selected_rsm.value}'
GROUP BY support_status
```

<ECharts config={
    {
        title: {
            text: 'Revenue by Support Status',
            left: 'center'
        },
        tooltip: {
            formatter: '{b}: ${value} ({d}%)'
        },
        legend: {
            orient: 'vertical',
            left: 'left'
        },
        series: [
        {
          type: 'pie',
          radius: '50%',
          data: [...support_status_pie],
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    }
}
/>
