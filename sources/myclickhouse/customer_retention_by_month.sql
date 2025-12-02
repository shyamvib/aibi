WITH all_first_orders AS (
    -- First-ever order per customer
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM business_intelligence.canonical_integrated_orders
    GROUP BY customer_id
),
new_customers_2025 AS (
    -- Only customers whose first-ever order is in 2025
    SELECT
        a.customer_id,
        a.first_order_date,
        toStartOfMonth(a.first_order_date) AS first_order_month
    FROM all_first_orders a
    WHERE a.first_order_date >= '2025-01-01'
),
monthly_activity AS (
    -- All activity during 2025 for these new customers
    SELECT
        nc.customer_id,
        nc.first_order_month,
        toStartOfMonth(o.order_date) AS activity_month
    FROM new_customers_2025 nc
    JOIN business_intelligence.canonical_integrated_orders o 
        ON nc.customer_id = o.customer_id
    WHERE o.order_date >= '2025-01-01'
)
SELECT
    first_order_month,
    formatDateTime(first_order_month, '%Y-%m') AS month_label,
    countDistinct(customer_id) AS new_customers,
    -- Retention by month (active in or after each month)
    countDistinctIf(customer_id, activity_month >= '2025-01-01') AS active_through_jan,
    countDistinctIf(customer_id, activity_month >= '2025-02-01') AS active_through_feb,
    countDistinctIf(customer_id, activity_month >= '2025-03-01') AS active_through_mar,
    countDistinctIf(customer_id, activity_month >= '2025-04-01') AS active_through_apr,
    countDistinctIf(customer_id, activity_month >= '2025-05-01') AS active_through_may,
    countDistinctIf(customer_id, activity_month >= '2025-06-01') AS active_through_jun,
    countDistinctIf(customer_id, activity_month >= '2025-07-01') AS active_through_jul,
    countDistinctIf(customer_id, activity_month >= '2025-08-01') AS active_through_aug,
    countDistinctIf(customer_id, activity_month >= '2025-09-01') AS active_through_sep,
    countDistinctIf(customer_id, activity_month >= '2025-10-01') AS active_through_oct,
    countDistinctIf(customer_id, activity_month >= '2025-11-01') AS active_through_nov,
    countDistinctIf(customer_id, activity_month >= '2025-12-01') AS active_through_dec
FROM monthly_activity
GROUP BY first_order_month, month_label
ORDER BY first_order_month;