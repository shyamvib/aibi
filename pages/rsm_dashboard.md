---
title: RSM Performance Dashboard
---

## 2025 Revenue by Segment & Support Status

```sql rsm_data
SELECT * FROM rsm_performance_data  
WHERE rsm_name IS NOT NULL
AND rsm_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
```

```sql total_metrics
SELECT 
    SUM(CAST(revenue AS DOUBLE)) as total_revenue,
    SUM(CAST(customers AS INTEGER)) as total_customers,
    SUM(CAST(revenue AS DOUBLE)) / SUM(CAST(orders AS INTEGER)) as total_aov
FROM ${rsm_data}
```

<BigValue
  data={total_metrics}
  value=total_revenue
  title="Total 2025 Revenue"
  format="$,.1f"
/>

<BigValue
  data={total_metrics}
  value=total_customers
  title="Total Customers"
  format=","
/>

<BigValue
  data={total_metrics}
  value=total_aov
  title="Average Order Value"
  format="$,.2f"
/>

```sql lead_metrics
WITH lead_data AS (
    SELECT 
        rsm_name,
        SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as total_leads,
        SUM(CAST(calls AS INTEGER)) as total_calls,
        SUM(CAST(meetings AS INTEGER)) as total_meetings
    FROM leads_engagement
    WHERE rsm_name IS NOT NULL
    AND rsm_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
    GROUP BY rsm_name
),
customer_data AS (
    SELECT 
        rsm_name,
        SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END) as new_customers_2025
    FROM rsm_performance_data
    GROUP BY rsm_name
)
SELECT
    SUM(ld.total_leads) as total_leads,
    SUM(ld.total_calls) as total_lead_calls,
    SUM(ld.total_meetings) as total_lead_meetings,
    SUM(cd.new_customers_2025) as total_new_customers,
    ROUND(SUM(cd.new_customers_2025) / NULLIF(SUM(cd.new_customers_2025) + SUM(ld.total_leads), 0) * 100, 1) as overall_conversion_rate,
    ROUND(SUM(ld.total_calls + ld.total_meetings) / NULLIF(SUM(ld.total_leads), 0), 1) as avg_touchpoints_per_lead
FROM lead_data ld
LEFT JOIN customer_data cd ON ld.rsm_name = cd.rsm_name
```

<BigValue
  data={lead_metrics}
  value=total_leads
  title="Total Engaged Leads (No Orders)"
  format=","
/>

<!-- <BigValue
  data={lead_metrics}
  value=total_new_customers
  title="New Customers (2025)"
  format=","
/> -->


## EXECUTIVE SUMMARY

```sql revenue_by_segment
SELECT 
    customer_segment,
    SUM(CAST(revenue AS DOUBLE)) as revenue,
    SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM ${rsm_data}) * 100 as revenue_percent,
    SUM(CAST(customers AS INTEGER)) as customers,
    SUM(CAST(customers AS INTEGER)) / (SELECT SUM(CAST(customers AS INTEGER)) FROM ${rsm_data}) * 100 as customer_percent,
    SUM(CAST(orders AS INTEGER)) as orders
FROM ${rsm_data}
GROUP BY customer_segment
ORDER BY revenue DESC
```

```sql revenue_by_support
SELECT 
    support_status,
    SUM(CAST(revenue AS DOUBLE)) as revenue,
    SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM ${rsm_data}) * 100 as revenue_percent,
    SUM(CAST(customers AS INTEGER)) as customers,
    SUM(CAST(customers AS INTEGER)) / (SELECT SUM(CAST(customers AS INTEGER)) FROM ${rsm_data}) * 100 as customer_percent,
    SUM(CAST(orders AS INTEGER)) as orders
FROM ${rsm_data}
GROUP BY support_status
ORDER BY revenue DESC
```

<!-- ```sql best_segment
SELECT 
    customer_segment,
    support_status,
    SUM(CAST(revenue AS DOUBLE)) as revenue,
    SUM(CAST(revenue AS DOUBLE)) / (SELECT SUM(CAST(revenue AS DOUBLE)) FROM ${rsm_data}) * 100 as revenue_percent,
    SUM(CAST(customers AS INTEGER)) as customers,
    SUM(CAST(orders AS INTEGER)) as orders,
    SUM(CAST(revenue AS DOUBLE)) / SUM(CAST(orders AS INTEGER)) as aov
FROM ${rsm_data}
WHERE customer_segment = 'Existing (Pre-2025)' AND support_status = 'With Support'
GROUP BY customer_segment, support_status
``` -->

### Revenue by Customer Segment:



<DataTable
  data={revenue_by_segment}
  columns={[
    {id: "customer_segment", header: "Segment"},
    {id: "revenue", header: "Revenue", format: "$,.1f"},
    {id: "revenue_percent", header: "% of Total", format: ".1f%"},
    {id: "customers", header: "Customers", format: ","},
    {id: "customer_percent", header: "% of Total", format: ".1f%"},
    {id: "orders", header: "Orders", format: ","}
  ]}
/>

### Customer Counts:

```sql pie_data
SELECT 
    customer_segment as name,
    CAST(customers AS INTEGER) as value
FROM ${revenue_by_segment}
```

<ECharts config={
    {
        title: {
            text: 'Customer Distribution by Segment',
            left: 'center'
        },
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
        legend: {
            orient: 'vertical',
            left: 'left'
        },
        series: [
        {
          type: 'pie',
          radius: '50%',
          data: [...pie_data],
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

### By Support Status:

```sql support_pie_data
SELECT 
    support_status as name,
    CAST(revenue AS DOUBLE) as value
FROM ${revenue_by_support}
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
          data: [...support_pie_data],
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



<DataTable
  data={revenue_by_support}
  columns={[
    {id: "support_status", header: "Support Status"},
    {id: "revenue", header: "Revenue", format: "$,.1f"},
    {id: "revenue_percent", header: "% of Total", format: ".1f%"},
    {id: "customers", header: "Customers", format: ","},
    {id: "customer_percent", header: "% of Total", format: ".1f%"},
    {id: "orders", header: "Orders", format: ","}
  ]}
/>

<!-- ### Best Segment: Existing + Support

<BigValue
  data={best_segment}
  value=revenue
  title="Revenue"
  format="$,.1f"
/>

<BigValue
  data={best_segment}
  value=revenue_percent
  title="% of Total Revenue"
  format=".1f%"
/>

<BigValue
  data={best_segment}
  value=customers
  title="Customers"
  format=","
/>

<BigValue
  data={best_segment}
  value=orders
  title="Orders"
  format=","
/>

<BigValue
  data={best_segment}
  value=aov
  title="Average Order Value"
  format="$,.0f"
/> -->

---

## Monthly Performance Overview

```sql rsm_monthly_data
SELECT * FROM rsm_monthly_performance
```



```sql monthly_summary
SELECT 
    month_label,
    month_date,
    SUM(CAST(revenue AS DOUBLE)) as total_revenue,
    SUM(CAST(orders AS INTEGER)) as total_orders,
    SUM(CAST(active_customers_this_month AS INTEGER)) as total_customers,
    SUM(CAST(total_calls AS INTEGER)) as total_calls,
    SUM(CAST(total_meetings AS INTEGER)) as total_meetings
FROM ${rsm_monthly_data}
GROUP BY month_label, month_date
ORDER BY month_date
```

```sql total_new_customers
SELECT
    SUM(CASE WHEN customer_segment = 'One-Timer (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as one_timers,
    SUM(CASE WHEN customer_segment = 'Repeat (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as repeat_customers,
    SUM(CASE WHEN customer_segment IN ('One-Timer (2025)', 'Repeat (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END) as total_new_customers
FROM ${rsm_data}
```

```sql first_orders_data
SELECT * FROM first_orders_by_month
```

```sql new_customers_monthly
SELECT
    month_label,
    month_date,
    SUM(CAST(new_customers AS INTEGER)) as new_customers
FROM ${first_orders_data}
GROUP BY month_label, month_date
ORDER BY month_date
```

```sql customer_retention_data
SELECT * FROM customer_retention_by_month
```

```sql customer_retention_long
SELECT
    first_order_month as month_date,
    month_label,
    new_customers,
    active_through_jan,
    active_through_feb,
    active_through_mar,
    active_through_apr,
    active_through_may,
    active_through_jun,
    active_through_jul,
    active_through_aug,
    active_through_sep,
    active_through_oct,
    active_through_nov,
    active_through_dec
FROM ${customer_retention_data}
ORDER BY month_date
```

```sql mom_growth_rate
WITH monthly_new AS (
    SELECT 
        month_label,
        month_date,
        CAST(new_customers AS INTEGER) as new_customers,
        LAG(CAST(new_customers AS INTEGER)) OVER (ORDER BY month_date) as prev_month_customers
    FROM ${new_customers_monthly}
),
growth_rates AS (
    SELECT 
        month_label,
        month_date,
        new_customers,
        prev_month_customers,
        CASE 
            WHEN prev_month_customers > 0 THEN (new_customers - prev_month_customers) * 100.0 / prev_month_customers
            ELSE NULL
        END as growth_rate
    FROM monthly_new
    WHERE prev_month_customers IS NOT NULL
)
SELECT 
    AVG(growth_rate) as avg_mom_growth_rate
FROM growth_rates
WHERE growth_rate IS NOT NULL
```

```sql active_customer_growth_rate
WITH monthly_active AS (
    SELECT 
        month,
        month_num,
        CAST(active_customers AS INTEGER) as active_customers,
        LAG(CAST(active_customers AS INTEGER)) OVER (ORDER BY month_num) as prev_month_active
    FROM ${monthly_active_customers}
),
growth_rates AS (
    SELECT 
        month,
        month_num,
        active_customers,
        prev_month_active,
        CASE 
            WHEN prev_month_active > 0 THEN (active_customers - prev_month_active) * 100.0 / prev_month_active
            ELSE NULL
        END as growth_rate
    FROM monthly_active
    WHERE prev_month_active IS NOT NULL
)
SELECT 
    AVG(growth_rate) as avg_active_growth_rate
FROM growth_rates
WHERE growth_rate IS NOT NULL
```

<BigValue
  data={total_new_customers}
  value=total_new_customers
  title="Total New Customers (2025)"
  format=","
/>

<BigValue
  data={total_new_customers}
  value=one_timers
  title="One-Time Customers"
  format=","
/>

<BigValue
  data={total_new_customers}
  value=repeat_customers
  title="Repeat Customers"
  format=","
/>

<BigValue
  data={mom_growth_rate}
  value=avg_mom_growth_rate
  title="Avg Monthly Growth Rate (New Customers)"
  format="+.1f%"
/>

<BigValue
  data={active_customer_growth_rate}
  value=avg_active_growth_rate
  title="Avg Monthly Growth Rate (Active Customers)"
  format="+.1f%"
/>

```sql active_customers_by_month
SELECT
    month_label,
    month_date,
    CAST(active_through_jan AS INTEGER) as jan_active,
    CAST(active_through_feb AS INTEGER) as feb_active,
    CAST(active_through_mar AS INTEGER) as mar_active,
    CAST(active_through_apr AS INTEGER) as apr_active,
    CAST(active_through_may AS INTEGER) as may_active,
    CAST(active_through_jun AS INTEGER) as jun_active,
    CAST(active_through_jul AS INTEGER) as jul_active,
    CAST(active_through_aug AS INTEGER) as aug_active,
    CAST(active_through_sep AS INTEGER) as sep_active,
    CAST(active_through_oct AS INTEGER) as oct_active,
    CAST(active_through_nov AS INTEGER) as nov_active,
    CAST(active_through_dec AS INTEGER) as dec_active
FROM ${customer_retention_long}
ORDER BY month_date
```

```sql cumulative_new_customers
WITH monthly_new AS (
    SELECT
        month_label,
        month_date,
        CAST(new_customers AS INTEGER) as new_customers,
        CASE 
            WHEN month_label LIKE '%01' OR month_label LIKE '%-1' THEN 1
            WHEN month_label LIKE '%02' OR month_label LIKE '%-2' THEN 2
            WHEN month_label LIKE '%03' OR month_label LIKE '%-3' THEN 3
            WHEN month_label LIKE '%04' OR month_label LIKE '%-4' THEN 4
            WHEN month_label LIKE '%05' OR month_label LIKE '%-5' THEN 5
            WHEN month_label LIKE '%06' OR month_label LIKE '%-6' THEN 6
            WHEN month_label LIKE '%07' OR month_label LIKE '%-7' THEN 7
            WHEN month_label LIKE '%08' OR month_label LIKE '%-8' THEN 8
            WHEN month_label LIKE '%09' OR month_label LIKE '%-9' THEN 9
            WHEN month_label LIKE '%10' THEN 10
            WHEN month_label LIKE '%11' THEN 11
            WHEN month_label LIKE '%12' THEN 12
            ELSE 0
        END as month_num
    FROM ${new_customers_monthly}
),
cumulative AS (
    SELECT
        month_label,
        month_date,
        month_num,
        new_customers,
        SUM(new_customers) OVER (ORDER BY month_date) as cumulative_customers
    FROM monthly_new
)
SELECT
    CASE 
        WHEN month_num = 1 THEN 'Jan'
        WHEN month_num = 2 THEN 'Feb'
        WHEN month_num = 3 THEN 'Mar'
        WHEN month_num = 4 THEN 'Apr'
        WHEN month_num = 5 THEN 'May'
        WHEN month_num = 6 THEN 'Jun'
        WHEN month_num = 7 THEN 'Jul'
        WHEN month_num = 8 THEN 'Aug'
        WHEN month_num = 9 THEN 'Sep'
        WHEN month_num = 10 THEN 'Oct'
        WHEN month_num = 11 THEN 'Nov'
        WHEN month_num = 12 THEN 'Dec'
        ELSE month_label
    END as month,
    month_date,
    month_num,
    cumulative_customers as total_new_customers
FROM cumulative
ORDER BY month_num
```

```sql monthly_active_customers
WITH jan_active AS (
    SELECT
        '2025-01-01' as month_date,
        'Jan' as month_name,
        1 as month_num,
        SUM(CAST(active_through_jan AS INTEGER)) - SUM(CAST(active_through_feb AS INTEGER)) as active_customers,
        SUM(CAST(active_through_jan AS INTEGER)) - SUM(CAST(active_through_feb AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
feb_active AS (
    SELECT
        '2025-02-01' as month_date,
        'Feb' as month_name,
        2 as month_num,
        SUM(CAST(active_through_feb AS INTEGER)) - SUM(CAST(active_through_mar AS INTEGER)) as active_customers,
        SUM(CAST(active_through_feb AS INTEGER)) - SUM(CAST(active_through_mar AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
mar_active AS (
    SELECT
        '2025-03-01' as month_date,
        'Mar' as month_name,
        3 as month_num,
        SUM(CAST(active_through_mar AS INTEGER)) - SUM(CAST(active_through_apr AS INTEGER)) as active_customers,
        SUM(CAST(active_through_mar AS INTEGER)) - SUM(CAST(active_through_apr AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
apr_active AS (
    SELECT
        '2025-04-01' as month_date,
        'Apr' as month_name,
        4 as month_num,
        SUM(CAST(active_through_apr AS INTEGER)) - SUM(CAST(active_through_may AS INTEGER)) as active_customers,
        SUM(CAST(active_through_apr AS INTEGER)) - SUM(CAST(active_through_may AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
may_active AS (
    SELECT
        '2025-05-01' as month_date,
        'May' as month_name,
        5 as month_num,
        SUM(CAST(active_through_may AS INTEGER)) - SUM(CAST(active_through_jun AS INTEGER)) as active_customers,
        SUM(CAST(active_through_may AS INTEGER)) - SUM(CAST(active_through_jun AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
jun_active AS (
    SELECT
        '2025-06-01' as month_date,
        'Jun' as month_name,
        6 as month_num,
        SUM(CAST(active_through_jun AS INTEGER)) - SUM(CAST(active_through_jul AS INTEGER)) as active_customers,
        SUM(CAST(active_through_jun AS INTEGER)) - SUM(CAST(active_through_jul AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
jul_active AS (
    SELECT
        '2025-07-01' as month_date,
        'Jul' as month_name,
        7 as month_num,
        SUM(CAST(active_through_jul AS INTEGER)) - SUM(CAST(active_through_aug AS INTEGER)) as active_customers,
        SUM(CAST(active_through_jul AS INTEGER)) - SUM(CAST(active_through_aug AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
aug_active AS (
    SELECT
        '2025-08-01' as month_date,
        'Aug' as month_name,
        8 as month_num,
        SUM(CAST(active_through_aug AS INTEGER)) - SUM(CAST(active_through_sep AS INTEGER)) as active_customers,
        SUM(CAST(active_through_aug AS INTEGER)) - SUM(CAST(active_through_sep AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
sep_active AS (
    SELECT
        '2025-09-01' as month_date,
        'Sep' as month_name,
        9 as month_num,
        SUM(CAST(active_through_sep AS INTEGER)) - SUM(CAST(active_through_oct AS INTEGER)) as active_customers,
        SUM(CAST(active_through_sep AS INTEGER)) - SUM(CAST(active_through_oct AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
oct_active AS (
    SELECT
        '2025-10-01' as month_date,
        'Oct' as month_name,
        10 as month_num,
        SUM(CAST(active_through_oct AS INTEGER)) - SUM(CAST(active_through_nov AS INTEGER)) as active_customers,
        SUM(CAST(active_through_oct AS INTEGER)) - SUM(CAST(active_through_nov AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
nov_active AS (
    SELECT
        '2025-11-01' as month_date,
        'Nov' as month_name,
        11 as month_num,
        SUM(CAST(active_through_nov AS INTEGER)) - SUM(CAST(active_through_dec AS INTEGER)) as active_customers,
        SUM(CAST(active_through_nov AS INTEGER)) - SUM(CAST(active_through_dec AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
dec_active AS (
    SELECT
        '2025-12-01' as month_date,
        'Dec' as month_name,
        12 as month_num,
        SUM(CAST(active_through_dec AS INTEGER)) as active_customers,
        SUM(CAST(active_through_dec AS INTEGER)) as value_for_color
    FROM ${customer_retention_long}
),
all_months AS (
    SELECT * FROM jan_active
    UNION ALL SELECT * FROM feb_active
    UNION ALL SELECT * FROM mar_active
    UNION ALL SELECT * FROM apr_active
    UNION ALL SELECT * FROM may_active
    UNION ALL SELECT * FROM jun_active
    UNION ALL SELECT * FROM jul_active
    UNION ALL SELECT * FROM aug_active
    UNION ALL SELECT * FROM sep_active
    UNION ALL SELECT * FROM oct_active
    UNION ALL SELECT * FROM nov_active
    UNION ALL SELECT * FROM dec_active
)
SELECT
    month_name as month,
    month_date,
    month_num,
    active_customers,
    value_for_color,
    ROUND(
        CASE 
            WHEN LAG(active_customers) OVER (ORDER BY month_num) = 0 THEN NULL
            ELSE (active_customers - LAG(active_customers) OVER (ORDER BY month_num)) * 100.0 / LAG(active_customers) OVER (ORDER BY month_num)
        END, 1
    ) as mom_pct_change
FROM all_months
ORDER BY month_num 
```

<!-- <LineChart
  data={cumulative_new_customers}
  x="month"
  y="total_new_customers"
  yAxisTitle="Cumulative New Customers"
  title="Cumulative New Customer Acquisitions (2025)"
  formatY=","
  xSort="month_num"
/> -->

<!-- <LineChart
  data={new_customers_monthly}
  x="month_label"
  y="new_customers"
  yAxisTitle="New Customers"
  title="Monthly New Customer Acquisitions (2025)"
  formatY=","
  xSort="month_date"
/> -->

### Monthly Active Customers (2025)
<DataTable 
  data={monthly_active_customers}
  search={false}
  rows=12
  rowNavigation={false}
>
  <Column id=month name="Month" />
  <Column id=active_customers name="Active Customers" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
  <Column id=mom_pct_change name="MoM % Change" 
    format="+.1f%"
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin={-100}
    colorScaleMax={100} />
</DataTable>

```sql customer_retention_by_cohort
SELECT
    month_label,
    new_customers,
    ROUND(CAST(active_through_feb AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as feb_retention,
    ROUND(CAST(active_through_mar AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as mar_retention,
    ROUND(CAST(active_through_apr AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as apr_retention,
    ROUND(CAST(active_through_may AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as may_retention,
    ROUND(CAST(active_through_jun AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as jun_retention,
    ROUND(CAST(active_through_jul AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as jul_retention,
    ROUND(CAST(active_through_aug AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as aug_retention,
    ROUND(CAST(active_through_sep AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as sep_retention,
    ROUND(CAST(active_through_oct AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as oct_retention,
    ROUND(CAST(active_through_nov AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as nov_retention,
    ROUND(CAST(active_through_dec AS DOUBLE) * 100.0 / NULLIF(CAST(new_customers AS DOUBLE), 0), 1) as dec_retention
FROM ${customer_retention_long}
WHERE month_date < '2025-12-01'
ORDER BY month_date
```

<DataTable
  data={customer_retention_long}
  columns={[
    {id: "month_label", header: "Month"},
    {id: "new_customers", header: "New Customers", format: ","},
    {id: "active_through_jan", header: "Jan", format: ","},
    {id: "active_through_feb", header: "Feb", format: ","},
    {id: "active_through_mar", header: "Mar", format: ","},
    {id: "active_through_apr", header: "Apr", format: ","},
    {id: "active_through_may", header: "May", format: ","},
    {id: "active_through_jun", header: "Jun", format: ","},
    {id: "active_through_jul", header: "Jul", format: ","},
    {id: "active_through_aug", header: "Aug", format: ","},
    {id: "active_through_sep", header: "Sep", format: ","},
    {id: "active_through_oct", header: "Oct", format: ","},
    {id: "active_through_nov", header: "Nov", format: ","},
    {id: "active_through_dec", header: "Dec", format: ","}
  ]}
  title="Customer Retention by Month (2025)"
/>

<DataTable
  data={customer_retention_by_cohort}
  columns={[
    {id: "month_label", header: "Cohort"},
    {id: "new_customers", header: "New Customers", format: ","},
    {id: "feb_retention", header: "Feb", format: ".1f%"},
    {id: "mar_retention", header: "Mar", format: ".1f%"},
    {id: "apr_retention", header: "Apr", format: ".1f%"},
    {id: "may_retention", header: "May", format: ".1f%"},
    {id: "jun_retention", header: "Jun", format: ".1f%"},
    {id: "jul_retention", header: "Jul", format: ".1f%"},
    {id: "aug_retention", header: "Aug", format: ".1f%"},
    {id: "sep_retention", header: "Sep", format: ".1f%"},
    {id: "oct_retention", header: "Oct", format: ".1f%"},
    {id: "nov_retention", header: "Nov", format: ".1f%"},
    {id: "dec_retention", header: "Dec", format: ".1f%"}
  ]}
  title="Customer Retention Rate by Cohort (2025)"
/>

```sql retention_heatmap
SELECT
    month_label,
    CAST(feb_retention AS DOUBLE) as feb,
    CAST(mar_retention AS DOUBLE) as mar,
    CAST(apr_retention AS DOUBLE) as apr,
    CAST(may_retention AS DOUBLE) as may,
    CAST(jun_retention AS DOUBLE) as jun,
    CAST(jul_retention AS DOUBLE) as jul,
    CAST(aug_retention AS DOUBLE) as aug,
    CAST(sep_retention AS DOUBLE) as sep,
    CAST(oct_retention AS DOUBLE) as oct,
    CAST(nov_retention AS DOUBLE) as nov,
    CAST(dec_retention AS DOUBLE) as dec
FROM ${customer_retention_by_cohort}
ORDER BY month_label
```

<ECharts config={{
    tooltip: {
        position: 'top',
        formatter: function (params) {
            return params.seriesName + ' cohort in ' + params.name + ': ' + params.value.toFixed(1) + '%';
        }
    },
    grid: {
        height: '70%',
        top: '15%'
    },
    xAxis: {
        type: 'category',
        data: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        splitArea: {
            show: true
        }
    },
    yAxis: {
        type: 'category',
        data: retention_heatmap.map(d => d.month_label),
        splitArea: {
            show: true
        }
    },
    visualMap: {
        min: 0,
        max: 100,
        calculable: true,
        orient: 'horizontal',
        left: 'center',
        bottom: '0%',
        text: ['100%', '0%'],
        color: ['#52c41a', '#fadb14', '#f5222d']
    },
    series: retention_heatmap.map(row => ({
        name: row.month_label,
        type: 'heatmap',
        data: [
            [0, row.month_label, row.feb || 0],
            [1, row.month_label, row.mar || 0],
            [2, row.month_label, row.apr || 0],
            [3, row.month_label, row.may || 0],
            [4, row.month_label, row.jun || 0],
            [5, row.month_label, row.jul || 0],
            [6, row.month_label, row.aug || 0],
            [7, row.month_label, row.sep || 0],
            [8, row.month_label, row.oct || 0],
            [9, row.month_label, row.nov || 0],
            [10, row.month_label, row.dec || 0]
        ].filter(item => !isNaN(item[2])),
        label: {
            show: true,
            formatter: function(params) {
                return params.value[2].toFixed(1) + '%';
            }
        },
        emphasis: {
            itemStyle: {
                shadowBlur: 10,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
        }
    }))
}}
  title="Customer Retention Heatmap (2025)"
/>


```sql monthly_new_customers
WITH base_data AS (
    SELECT
        month_label,
        month_date,
        customer_segment,
        support_status,
        SUM(CAST(new_customers AS INTEGER)) as new_customers
    FROM ${first_orders_data}
    GROUP BY month_label, month_date, customer_segment, support_status
)
SELECT 
    month_label,
    month_date,
    customer_segment,
    support_status,
    new_customers,
    new_customers as value_for_color
FROM base_data
WHERE (customer_segment = '${inputs.monthly_segment_filter}' OR '${inputs.monthly_segment_filter}' = 'All')
  AND (support_status = '${inputs.monthly_support_filter}' OR '${inputs.monthly_support_filter}' = 'All')
ORDER BY month_date, customer_segment, support_status
```

### Monthly New Customers

<ButtonGroup name="monthly_segment_filter" valueLabel="Customer Segment">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All Segments</ButtonGroupItem>
  <ButtonGroupItem value="Repeat (2025)" valueLabel="Repeat">Repeat (2025)</ButtonGroupItem>
  <ButtonGroupItem value="One-Timer (2025)" valueLabel="One-Timer">One-Timer (2025)</ButtonGroupItem>
  <ButtonGroupItem value="Existing (Pre-2025)" valueLabel="Existing">Existing (Pre-2025)</ButtonGroupItem>
</ButtonGroup>

<ButtonGroup name="monthly_support_filter" valueLabel="Support Status">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All Support Status</ButtonGroupItem>
  <ButtonGroupItem value="No Support" valueLabel="No Support">No Support</ButtonGroupItem>
  <ButtonGroupItem value="With Support" valueLabel="With Support">With Support</ButtonGroupItem>
</ButtonGroup>

<DataTable 
  data={monthly_new_customers}
  search={false}
  rowNavigation={false}
>
  <Column id=month_label name="Month" />
  <Column id=customer_segment name="Customer Segment" />
  <Column id=support_status name="Support Status" />
  <Column id=new_customers name="New Customers" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
</DataTable>


## RSM Performance Analysis

```sql rsm_summary_by_support
SELECT 
    rsm_name,
    support_status,
    SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(revenue AS DOUBLE) ELSE 0 END) as revenue,
    SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END) as customers
FROM ${rsm_data}
WHERE customer_segment IN ('Repeat (2025)', 'One-Timer (2025)')
GROUP BY rsm_name, support_status
ORDER BY rsm_name, support_status
```

```sql rsm_summary
SELECT 
    rsm_name,
    SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(revenue AS DOUBLE) ELSE 0 END) as total_revenue,
    SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END) as total_customers
FROM ${rsm_data}
GROUP BY rsm_name
ORDER BY total_revenue DESC
```

<BarChart
  data={rsm_summary_by_support}
  x=rsm_name
  y=revenue
  series=support_status
  yAxisTitle="Revenue ($M)"
  title="New Customer Revenue by RSM and Support Status (2025)"
  xAxisTitle="RSM"
  formatY="$,.1f"
  xAxisLabelRotate=90
/>

<BarChart
  data={rsm_summary_by_support}
  x=rsm_name
  y=customers
  series=support_status
  yAxisTitle="Customer Count"
  title="New Customers by RSM and Support Status (2025)"
  xAxisTitle="RSM"
  formatY=","
  xAxisLabelRotate=90
/>

For detailed analysis of individual RSMs, please visit the [RSM Detail View](/rsm_detail) page.

---


## Retention Rate Analysis

```sql retention_data
SELECT 
    rsm_name,
    SUM(CASE WHEN customer_segment = 'Repeat (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as repeat_customers,
    SUM(CASE WHEN customer_segment = 'One-Timer (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as one_time_customers
FROM ${rsm_data}
GROUP BY rsm_name
```

```sql retention_rates
SELECT 
    rsm_name,
    repeat_customers,
    one_time_customers,
    repeat_customers + one_time_customers as new_customers_total,
    repeat_customers * 100.0 / NULLIF(repeat_customers + one_time_customers, 0) as retention_rate
FROM ${retention_data}
ORDER BY retention_rate DESC
```

<BarChart
  data={retention_rates}
  x=rsm_name
  y=retention_rate
  yAxisTitle="Retention Rate (%)"
  title="Retention Rate by RSM"
  formatY=".1f%"
  xAxisLabelRotate=90
/>

### Best Retention Rates (Top 5)

```sql top_retention
SELECT * FROM ${retention_rates} ORDER BY retention_rate DESC LIMIT 5
```

<DataTable
  data={top_retention}
  columns={[
    {id: "rsm_name", header: "RSM"},
    {id: "retention_rate", header: "Retention %", format: ".1f%"},
    {id: "new_customers_total", header: "New Customers", format: ","},
    {id: "repeat_customers", header: "Repeat", format: ","},
    {id: "one_time_customers", header: "One-Timer", format: ","}
  ]}
/>

### Retention Rates (Bottom 5)

```sql bottom_retention
SELECT * FROM ${retention_rates} ORDER BY retention_rate ASC LIMIT 5
```

<DataTable
  data={bottom_retention}
  columns={[
    {id: "rsm_name", header: "RSM"},
    {id: "retention_rate", header: "Retention %", format: ".1f%"},
    {id: "new_customers_total", header: "New Customers", format: ","},
    {id: "repeat_customers", header: "Repeat", format: ","},
    {id: "one_time_customers", header: "One-Timer", format: ","}
  ]}
/>

---

## Support Status Analysis

```sql support_data
SELECT 
    rsm_name,
    SUM(CASE WHEN support_status = 'No Support' THEN CAST(customers AS INTEGER) ELSE 0 END) as unsupported_customers,
    SUM(CAST(customers AS INTEGER)) as total_customers
FROM ${rsm_data}
GROUP BY rsm_name
```

```sql unsupported_customers
SELECT 
    rsm_name,
    unsupported_customers,
    unsupported_customers * 100.0 / NULLIF(total_customers, 0) as unsupported_percent,
    total_customers
FROM ${support_data}
ORDER BY unsupported_percent DESC
```

<BarChart
  data={unsupported_customers}
  x=rsm_name
  y=unsupported_percent
  yAxisTitle="Unsupported Customers %"
  title="Unsupported Customers % by RSM"
  formatY=".1f%"
  xAxisLabelRotate=90
/>

### Most Unsupported Customers

```sql top_unsupported
SELECT * FROM ${unsupported_customers} ORDER BY unsupported_percent DESC LIMIT 5
```

<DataTable
  data={top_unsupported}
  columns={[
    {id: "rsm_name", header: "RSM"},
    {id: "unsupported_customers", header: "Unsupported", format: ","},
    {id: "unsupported_percent", header: "% Unsupported", format: ".1f%"},
    {id: "total_customers", header: "Total Customers", format: ","}
  ]}
/>

---

## 💡 KEY INSIGHTS

### Support Impact on Retention

```sql support_impact
SELECT 
    support_status,
    SUM(CASE WHEN customer_segment = 'Repeat (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as repeat_customers,
    SUM(CASE WHEN customer_segment = 'One-Timer (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) as one_time_customers,
    SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END) as total_new_customers,
    SUM(CASE WHEN customer_segment = 'Repeat (2025)' THEN CAST(customers AS INTEGER) ELSE 0 END) * 100.0 / 
    NULLIF(SUM(CASE WHEN customer_segment IN ('Repeat (2025)', 'One-Timer (2025)') THEN CAST(customers AS INTEGER) ELSE 0 END), 0) as retention_rate
FROM ${rsm_data}
GROUP BY support_status
```

<DataTable
  data={support_impact}
  columns={[
    {id: "support_status", header: "Support Status"},
    {id: "total_new_customers", header: "New Customers", format: ","},
    {id: "repeat_customers", header: "Repeat", format: ","},
    {id: "one_time_customers", header: "One-Timer", format: ","},
    {id: "retention_rate", header: "Retention Rate", format: ".1f%"}
  ]}
/>

```sql retention_donut_data
SELECT 
    support_status || ' (' || CAST(ROUND(retention_rate, 1) AS VARCHAR) || '%)' as name,
    CAST(total_new_customers AS INTEGER) as value
FROM ${support_impact}
```

<ECharts config={
    {
        title: {
            text: 'Support Status Impact on Retention',
            left: 'center'
        },
        tooltip: {
            formatter: '{b}: {c} customers'
        },
        legend: {
            orient: 'vertical',
            left: 'left'
        },
        series: [
        {
          type: 'pie',
          radius: ['40%', '70%'],
          data: [...retention_donut_data],
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          },
          label: {
            show: true,
            formatter: '{b}: {c} customers'
          }
        }
      ]
    }
}
/>

---

## Lead Engagement Analysis

```sql lead_engagement_by_rsm
SELECT 
    rsm_name,
    SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as total_leads,
    SUM(CAST(calls AS INTEGER)) as total_calls,
    SUM(CAST(meetings AS INTEGER)) as total_meetings,
    ROUND(SUM(CAST(calls AS INTEGER) + CAST(meetings AS INTEGER)) / NULLIF(SUM(CAST(new_leads_engaged_no_order AS INTEGER)), 0), 1) as touchpoints_per_lead
FROM leads_engagement
WHERE rsm_name IN (
  'Daniel McElwain', 'Paige Chapman', 'William Maycock', 'Scott Sclar', 'Samantha Pender',
  'Michael Watkins', 'Sara Simiele', 'Elizabeth Munoz-Lebaron', 'Breanne Murcek', 'Sydney Blissick',
  'Brandon Tschetter', 'David L. Brown', 'Javier Alvarez', 'Christopher Dennison', 'Andrea Whitmarsh',
  'Kevin Sullivan', 'Mateo Freeman', 'Matthew Holtshouser', 'Madelyn Wiggins'
)
GROUP BY rsm_name
ORDER BY total_leads DESC
```

### Lead Engagement by RSM

<DataTable 
  data={lead_engagement_by_rsm}
  search={false}
  rowNavigation={false}
>
  <Column id=rsm_name name="RSM" />
  <Column id=total_leads name="Total Leads" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
  <Column id=total_calls name="Calls" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
  <Column id=total_meetings name="Meetings" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
  <Column id=touchpoints_per_lead name="Touchpoints per Lead" 
    format=".1f"
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
</DataTable>

```sql lead_conversion_by_rsm
WITH lead_data AS (
    SELECT 
        rsm_name,
        SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as total_leads
    FROM leads_engagement
    WHERE rsm_name IS NOT NULL
    AND rsm_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
    GROUP BY rsm_name
),
customer_data AS (
    SELECT 
        rsm_name,
        customer_segment,
        support_status,
        SUM(CAST(customers AS INTEGER)) as customers
    FROM rsm_performance_data
    WHERE customer_segment IN ('Repeat (2025)', 'One-Timer (2025)')
    GROUP BY rsm_name, customer_segment, support_status
),
filtered_customers AS (
    SELECT 
        rsm_name,
        SUM(customers) as filtered_customers
    FROM customer_data
    WHERE (customer_segment = '${inputs.conversion_segment_filter}' OR '${inputs.conversion_segment_filter}' = 'All')
      AND (support_status = '${inputs.conversion_support_filter}' OR '${inputs.conversion_support_filter}' = 'All')
    GROUP BY rsm_name
)
SELECT
    ld.rsm_name,
    ld.total_leads,
    COALESCE(fc.filtered_customers, 0) as new_customers,
    ROUND(COALESCE(fc.filtered_customers, 0) / NULLIF(COALESCE(fc.filtered_customers, 0) + ld.total_leads, 0) * 100, 1) as conversion_rate
FROM lead_data ld
LEFT JOIN filtered_customers fc ON ld.rsm_name = fc.rsm_name
WHERE ld.total_leads > 0
  AND (fc.filtered_customers > 0 OR '${inputs.conversion_segment_filter}' = 'All' OR '${inputs.conversion_support_filter}' = 'All')
ORDER BY conversion_rate DESC
```

### Lead Conversion Rate by RSM

<ButtonGroup name="conversion_segment_filter" valueLabel="Customer Segment">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All Segments</ButtonGroupItem>
  <ButtonGroupItem value="Repeat (2025)" valueLabel="Repeat">Repeat (2025)</ButtonGroupItem>
  <ButtonGroupItem value="One-Timer (2025)" valueLabel="One-Timer">One-Timer (2025)</ButtonGroupItem>
</ButtonGroup>

<ButtonGroup name="conversion_support_filter" valueLabel="Support Status">
  <ButtonGroupItem value="All" isDefault valueLabel="All">All Support Status</ButtonGroupItem>
  <ButtonGroupItem value="No Support" valueLabel="No Support">No Support</ButtonGroupItem>
  <ButtonGroupItem value="With Support" valueLabel="With Support">With Support</ButtonGroupItem>
</ButtonGroup>

<DataTable 
  data={lead_conversion_by_rsm}
  search={false}
  rowNavigation={false}
>
  <Column id=rsm_name name="RSM" />
  <Column id=total_leads name="Total Leads" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
  <Column id=new_customers name="New Customers" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
  <Column id=conversion_rate name="Conversion Rate" 
    format=".1f%"
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0
    colorScaleMax=100 />
</DataTable>

```sql monthly_lead_trend
SELECT 
    month_label,
    month_date,
    SUM(CAST(new_leads_engaged_no_order AS INTEGER)) as leads,
    SUM(CAST(calls AS INTEGER)) as calls,
    SUM(CAST(meetings AS INTEGER)) as meetings
FROM leads_engagement
WHERE rsm_name IN (
  'Daniel McElwain', 'Paige Chapman', 'William Maycock', 'Scott Sclar', 'Samantha Pender',
  'Michael Watkins', 'Sara Simiele', 'Elizabeth Munoz-Lebaron', 'Breanne Murcek', 'Sydney Blissick',
  'Brandon Tschetter', 'David L. Brown', 'Javier Alvarez', 'Christopher Dennison', 'Andrea Whitmarsh',
  'Kevin Sullivan', 'Mateo Freeman', 'Matthew Holtshouser', 'Madelyn Wiggins'
)
GROUP BY month_label, month_date
ORDER BY month_date
```

### Monthly Lead Engagement Trend

#### Monthly Leads Engaged (No Orders)
<DataTable 
  data={monthly_lead_trend}
  search={false}
  rowNavigation={false}
>
  <Column id=month_label name="Month" />
  <Column id=leads name="Leads Engaged (No Orders)" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
</DataTable>

```sql monthly_lead_activities
WITH calls_data AS (
    SELECT 
        month_label,
        month_date,
        'Calls' as activity_type,
        calls as count,
        calls as value_for_color
    FROM ${monthly_lead_trend}
),
meetings_data AS (
    SELECT 
        month_label,
        month_date,
        'Meetings' as activity_type,
        meetings as count,
        meetings as value_for_color
    FROM ${monthly_lead_trend}
)
SELECT * FROM calls_data
UNION ALL
SELECT * FROM meetings_data
ORDER BY month_date, activity_type
```

### Monthly Lead Activities

#### Monthly Lead Calls & Meetings
<DataTable 
  data={monthly_lead_activities}
  search={false}
  rowNavigation={false}
  groupBy=month_label
  groupByLabel=Month
>
  <Column id=activity_type name="Activity Type" />
  <Column id=count name="Count" 
    format=","
    contentType=colorscale 
    colorScale={['#ce5050','white','#6db678']} 
    colorScaleMin=0 />
</DataTable>

---

## Product Analysis

```sql product_data
SELECT * FROM product_analysis
WHERE rsm_name IN (
  'Daniel McElwain', 'Paige Chapman', 'William Maycock', 'Scott Sclar', 'Samantha Pender',
  'Michael Watkins', 'Sara Simiele', 'Elizabeth Munoz-Lebaron', 'Breanne Murcek', 'Sydney Blissick',
  'Brandon Tschetter', 'David L. Brown', 'Javier Alvarez', 'Christopher Dennison', 'Andrea Whitmarsh',
  'Kevin Sullivan', 'Mateo Freeman', 'Matthew Holtshouser', 'Madelyn Wiggins'
)
```

```sql product_list
SELECT DISTINCT
    test_name
FROM ${product_data}
ORDER BY test_name
```

<Dropdown name=selected_product data={product_list} value=test_name title="Select a Product">
  <DropdownOption value="ALL" valueLabel="All Products"/>
</Dropdown>

```sql rsm_product_ranking
SELECT 
    rsm_name,
    customer_segment,
    SUM(CAST(times_ordered AS INTEGER)) as orders,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as revenue
FROM ${product_data}
WHERE (test_name = '${inputs.selected_product.value}' OR '${inputs.selected_product.value}' = 'ALL')
    AND (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
GROUP BY rsm_name, customer_segment
ORDER BY orders DESC
```


### RSM Ranking by Product Orders: {inputs.selected_product.label}

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

```sql rsm_product_ranking_existing
SELECT 
    rsm_name,
    SUM(orders) as total_orders,
    SUM(revenue) as total_revenue
FROM ${rsm_product_ranking}
WHERE customer_segment = 'Existing (Pre-2025)'
GROUP BY rsm_name
ORDER BY total_orders DESC
LIMIT 10
```

<DataTable
  data={rsm_product_ranking_existing}
  columns={[
    {id: "rsm_name", header: "RSM"},
    {id: "total_orders", header: "Orders", format: ","},
    {id: "total_revenue", header: "Revenue", format: "$,.0f"}
  ]}
  title="Top RSMs by Orders from Existing Customers"
/>

```sql rsm_product_ranking_repeat
SELECT 
    rsm_name,
    SUM(orders) as total_orders,
    SUM(revenue) as total_revenue
FROM ${rsm_product_ranking}
WHERE customer_segment = 'Repeat (2025)'
GROUP BY rsm_name
ORDER BY total_orders DESC
LIMIT 10
```

<DataTable
  data={rsm_product_ranking_repeat}
  columns={[
    {id: "rsm_name", header: "RSM"},
    {id: "total_orders", header: "Orders", format: ","},
    {id: "total_revenue", header: "Revenue", format: "$,.0f"}
  ]}
  title="Top RSMs by Orders from Repeat Customers"
/>

```sql rsm_product_ranking_one_timer
SELECT 
    rsm_name,
    SUM(orders) as total_orders,
    SUM(revenue) as total_revenue
FROM ${rsm_product_ranking}
WHERE customer_segment = 'One-Timer (2025)'
GROUP BY rsm_name
ORDER BY total_orders DESC
LIMIT 10
```

<DataTable
  data={rsm_product_ranking_one_timer}
  columns={[
    {id: "rsm_name", header: "RSM"},
    {id: "total_orders", header: "Orders", format: ","},
    {id: "total_revenue", header: "Revenue", format: "$,.0f"}
  ]}
  title="Top RSMs by Orders from One-Time Customers"
/>

```sql top_test_revenue
SELECT 
    test_name as name,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)) / (SELECT SUM(CAST(total_test_value AS DOUBLE)) FROM ${product_data} 
        WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
        AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM ${product_data}
WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY test_name
ORDER BY value DESC
LIMIT 1
```

```sql top_test_orders
SELECT 
    test_name as name,
    SUM(CAST(times_ordered AS INTEGER)) as value,
    ROUND(SUM(CAST(times_ordered AS INTEGER)) / (SELECT SUM(CAST(times_ordered AS INTEGER)) FROM ${product_data} 
        WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
        AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM ${product_data}
WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY test_name
ORDER BY value DESC
LIMIT 1
```

```sql top_bundle
SELECT 
    bundle_name as name,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)) / (SELECT SUM(CAST(total_test_value AS DOUBLE)) FROM ${product_data} 
        WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
        AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
    ) * 100, 1) as percentage
FROM ${product_data}
WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
    AND (customer_segment = '${inputs.product_segment_filter}' OR '${inputs.product_segment_filter}' = 'All')
GROUP BY bundle_name
ORDER BY value DESC
LIMIT 1
```

### Top Products

<BigValue
  data={top_test_revenue}
  value=name
  title="Top Test by Revenue"
/>

<BigValue
  data={top_test_revenue}
  value=value
  title="Revenue"
  format="$,.0f"
/>

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

<BigValue
  data={top_bundle}
  value=value
  title="Revenue"
  format="$,.0f"
/>

<BigValue
  data={top_bundle}
  value=percentage
  title="% of Total Revenue"
  format=".1f%"
/>

### Top Tests by Revenue

```sql top_tests_by_revenue
SELECT 
    test_name as name,
    SUM(CAST(times_ordered AS INTEGER)) as orders,
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as value
FROM ${product_data}
WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
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
    ROUND(SUM(CAST(total_test_value AS DOUBLE)), 0) as revenue
FROM ${product_data}
WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
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
WHERE (support_status = '${inputs.product_support_filter}' OR '${inputs.product_support_filter}' = 'All')
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

---

**Analysis Complete**  
**Date:** December 1, 2025  
**Analyst:** Business Intelligence Team
