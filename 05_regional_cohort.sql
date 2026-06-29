-- ============================================================
-- RETAIL SALES & CUSTOMER ANALYTICS
-- Query Set 4: Regional Performance & Cohort Retention
-- Author: Tauseef Ahmad Khan
-- ============================================================

-- ----------------------------------------------------------
-- 4.1 Regional Revenue vs Target
-- ----------------------------------------------------------
WITH regional_targets (region, target_revenue) AS (
    VALUES
        ('North',   6500000),
        ('South',   6000000),
        ('West',    5000000),
        ('East',    3200000),
        ('Central', 3000000)
),
regional_actual AS (
    SELECT
        o.region,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS actual_revenue,
        COUNT(DISTINCT o.customer_id)                                   AS customers
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE YEAR(o.order_date) = 2024
    GROUP BY o.region
)
SELECT
    a.region,
    a.actual_revenue,
    t.target_revenue,
    a.customers,
    ROUND((a.actual_revenue - t.target_revenue) / t.target_revenue * 100, 2) AS variance_pct,
    CASE
        WHEN a.actual_revenue >= t.target_revenue THEN 'Above Target'
        WHEN a.actual_revenue >= t.target_revenue * 0.95 THEN 'Near Target'
        ELSE 'Below Target'
    END                                                                  AS status
FROM regional_actual a
JOIN regional_targets t ON a.region = t.region
ORDER BY actual_revenue DESC;

-- ----------------------------------------------------------
-- 4.2 Cohort Retention Analysis
-- ----------------------------------------------------------
WITH cohort_base AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(order_date), '%Y-%m')           AS cohort_month,
        MIN(order_date)                                  AS first_order_date
    FROM orders
    WHERE status = 'Delivered'
    GROUP BY customer_id
),
customer_activity AS (
    SELECT
        o.customer_id,
        c.cohort_month,
        TIMESTAMPDIFF(
            MONTH, c.first_order_date, o.order_date
        )                                               AS month_number
    FROM orders o
    JOIN cohort_base c ON o.customer_id = c.customer_id
    WHERE o.status = 'Delivered'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_customers
    FROM cohort_base
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.month_number,
    COUNT(DISTINCT a.customer_id)                       AS retained_customers,
    cs.cohort_customers,
    ROUND(
        COUNT(DISTINCT a.customer_id) / cs.cohort_customers * 100, 1
    )                                                    AS retention_rate_pct
FROM customer_activity a
JOIN cohort_size cs ON a.cohort_month = cs.cohort_month
WHERE a.cohort_month BETWEEN '2024-01' AND '2024-06'
GROUP BY a.cohort_month, a.month_number, cs.cohort_customers
ORDER BY a.cohort_month, a.month_number;

-- ----------------------------------------------------------
-- 4.3 Sales Funnel Conversion Analysis
-- ----------------------------------------------------------
SELECT
    stage,
    COUNT(lead_id)                                          AS lead_count,
    ROUND(
        COUNT(lead_id) / FIRST_VALUE(COUNT(lead_id))
            OVER (ORDER BY
                CASE stage
                    WHEN 'Lead'        THEN 1
                    WHEN 'Prospect'    THEN 2
                    WHEN 'Qualified'   THEN 3
                    WHEN 'Negotiation' THEN 4
                    WHEN 'Closed Won'  THEN 5
                END
            ) * 100, 1
    )                                                        AS conversion_from_top_pct,
    LAG(COUNT(lead_id)) OVER (
        ORDER BY
            CASE stage
                WHEN 'Lead'        THEN 1
                WHEN 'Prospect'    THEN 2
                WHEN 'Qualified'   THEN 3
                WHEN 'Negotiation' THEN 4
                WHEN 'Closed Won'  THEN 5
            END
    )                                                        AS prev_stage_count
FROM sales_funnel
WHERE YEAR(lead_date) = 2024
GROUP BY stage
ORDER BY
    CASE stage
        WHEN 'Lead'        THEN 1
        WHEN 'Prospect'    THEN 2
        WHEN 'Qualified'   THEN 3
        WHEN 'Negotiation' THEN 4
        WHEN 'Closed Won'  THEN 5
    END;
