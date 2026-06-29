-- ============================================================
-- RETAIL SALES & CUSTOMER ANALYTICS
-- Query Set 3: Product & Category Analysis
-- Author: Tauseef Ahmad Khan
-- ============================================================

-- ----------------------------------------------------------
-- 3.1 Top 10 Products by Revenue (using RANK)
-- ----------------------------------------------------------
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)  AS total_revenue,
        SUM(oi.quantity)                                                  AS units_sold,
        ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
            / SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)))
                OVER () * 100, 2
        )                                                                 AS revenue_share_pct
    FROM order_items oi
    JOIN products p    ON oi.product_id = p.product_id
    JOIN orders o      ON oi.order_id = o.order_id
    WHERE YEAR(o.order_date) = 2024
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    RANK() OVER (ORDER BY total_revenue DESC)   AS rank_position,
    product_name,
    category,
    total_revenue,
    units_sold,
    revenue_share_pct
FROM product_revenue
ORDER BY rank_position
LIMIT 10;

-- ----------------------------------------------------------
-- 3.2 Revenue by Category
-- ----------------------------------------------------------
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)     AS category_revenue,
    COUNT(DISTINCT o.order_id)                                          AS total_orders,
    ROUND(AVG(oi.unit_price), 2)                                        AS avg_unit_price,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        / SUM(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)))
            OVER () * 100, 2
    )                                                                    AS pct_of_total
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o   ON oi.order_id = o.order_id
WHERE YEAR(o.order_date) = 2024
GROUP BY p.category
ORDER BY category_revenue DESC;

-- ----------------------------------------------------------
-- 3.3 Category Performance vs Previous Year
-- ----------------------------------------------------------
SELECT
    p.category,
    SUM(CASE WHEN YEAR(o.order_date) = 2024
        THEN oi.quantity * oi.unit_price * (1 - oi.discount) ELSE 0 END) AS revenue_2024,
    SUM(CASE WHEN YEAR(o.order_date) = 2023
        THEN oi.quantity * oi.unit_price * (1 - oi.discount) ELSE 0 END) AS revenue_2023,
    ROUND(
        (SUM(CASE WHEN YEAR(o.order_date) = 2024
             THEN oi.quantity * oi.unit_price * (1 - oi.discount) ELSE 0 END)
         - SUM(CASE WHEN YEAR(o.order_date) = 2023
             THEN oi.quantity * oi.unit_price * (1 - oi.discount) ELSE 0 END))
        / NULLIF(SUM(CASE WHEN YEAR(o.order_date) = 2023
             THEN oi.quantity * oi.unit_price * (1 - oi.discount) ELSE 0 END), 0) * 100, 2
    )                                                                     AS yoy_growth_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o   ON oi.order_id = o.order_id
WHERE YEAR(o.order_date) IN (2023, 2024)
GROUP BY p.category
ORDER BY revenue_2024 DESC;
