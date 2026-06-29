-- ============================================================
-- RETAIL SALES & CUSTOMER ANALYTICS
-- Query Set 1: KPI Calculations
-- Author: Tauseef Ahmad Khan
-- ============================================================

-- ----------------------------------------------------------
-- 1.1 Total Revenue, Orders & Customers (FY2024)
-- ----------------------------------------------------------
SELECT
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    COUNT(DISTINCT o.customer_id)                       AS active_customers,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)  AS total_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)  AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = 2024
  AND o.status = 'Delivered';

-- ----------------------------------------------------------
-- 1.2 Gross Margin %
-- ----------------------------------------------------------
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)     AS total_revenue,
    ROUND(SUM(oi.quantity * p.cost_price), 2)                           AS total_cost,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
         - SUM(oi.quantity * p.cost_price))
        / SUM(oi.quantity * oi.unit_price * (1 - oi.discount)) * 100, 2
    )                                                                    AS gross_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p    ON oi.product_id = p.product_id
WHERE YEAR(o.order_date) = 2024;

-- ----------------------------------------------------------
-- 1.3 Monthly Revenue & Profit Trend
-- ----------------------------------------------------------
SELECT
    DATE_FORMAT(o.order_date, '%b-%Y')                                  AS month_name,
    MONTH(o.order_date)                                                 AS month_num,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)     AS monthly_revenue,
    ROUND(
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
        - SUM(oi.quantity * p.cost_price), 2
    )                                                                    AS gross_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p    ON oi.product_id = p.product_id
WHERE YEAR(o.order_date) = 2024
GROUP BY month_name, month_num
ORDER BY month_num;

-- ----------------------------------------------------------
-- 1.4 YoY Revenue Growth
-- ----------------------------------------------------------
SELECT
    YEAR(o.order_date)                                                  AS year,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2)     AS total_revenue,
    LAG(ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2))
        OVER (ORDER BY YEAR(o.order_date))                              AS prev_year_revenue,
    ROUND(
        (SUM(oi.quantity * oi.unit_price * (1 - oi.discount))
         - LAG(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)))
             OVER (ORDER BY YEAR(o.order_date)))
        / LAG(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)))
             OVER (ORDER BY YEAR(o.order_date)) * 100, 2
    )                                                                    AS yoy_growth_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY year;
