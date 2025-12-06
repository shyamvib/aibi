-- Customer Segments Growth Analysis - Detailed View
WITH yearly AS (
    SELECT 
        customer_id,
        toYear(order_date) AS yr,
        SUM(total) AS total_revenue
    FROM business_intelligence.canonical_integrated_orders
    --WHERE sales_name NOT IN ('Suzi Hansen', 'Malek Bishawi', 'Kristina Banister')
    GROUP BY customer_id, yr
),
first_order AS (
    SELECT 
        customer_id,
        MIN(yr) AS first_year
    FROM yearly
    GROUP BY customer_id
),
base AS (
    SELECT 
        toString(yr) AS year,
        -- Active customers metrics
        count(DISTINCT customer_id) AS active_customers,
        sum(total_revenue) AS active_revenue,
        
        -- New customers metrics
        countIf(DISTINCT customer_id, first_year = yr) AS new_customers,
        sumIf(total_revenue, first_year = yr) AS new_revenue,
        
        -- Returning customers metrics
        countIf(DISTINCT customer_id, first_year < yr) AS returning_customers,
        sumIf(total_revenue, first_year < yr) AS returning_revenue
    FROM yearly y
    LEFT JOIN first_order f USING (customer_id)
    WHERE yr IN (2023, 2024, 2025)
    GROUP BY yr
    ORDER BY yr
)
SELECT
    year,
    -- Active customers
    active_customers,
    active_revenue,
    ROUND(active_customers / NULLIF(lagInFrame(active_customers) OVER (ORDER BY year), 0) - 1, 4) AS active_customers_yoy_growth,
    ROUND(active_revenue / NULLIF(lagInFrame(active_revenue) OVER (ORDER BY year), 0) - 1, 4) AS active_revenue_yoy_growth,
    
    -- New customers
    new_customers,
    new_revenue,
    ROUND(new_customers / NULLIF(lagInFrame(new_customers) OVER (ORDER BY year), 0) - 1, 4) AS new_customers_yoy_growth,
    ROUND(new_revenue / NULLIF(lagInFrame(new_revenue) OVER (ORDER BY year), 0) - 1, 4) AS new_revenue_yoy_growth,
    
    -- Returning customers
    returning_customers,
    returning_revenue,
    ROUND(returning_customers / NULLIF(lagInFrame(returning_customers) OVER (ORDER BY year), 0) - 1, 4) AS returning_customers_yoy_growth,
    ROUND(returning_revenue / NULLIF(lagInFrame(returning_revenue) OVER (ORDER BY year), 0) - 1, 4) AS returning_revenue_yoy_growth
FROM base
ORDER BY year;
