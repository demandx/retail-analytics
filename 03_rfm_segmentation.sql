-- ============================================================
-- RETAIL SALES & CUSTOMER ANALYTICS
-- Query Set 2: RFM Customer Segmentation
-- Author: Tauseef Ahmad Khan
-- ============================================================

-- ----------------------------------------------------------
-- 2.1 Base RFM Calculation
-- ----------------------------------------------------------
WITH rfm_base AS (
    SELECT
        o.customer_id,
        DATEDIFF(CURDATE(), MAX(o.order_date))                          AS recency_days,
        COUNT(DISTINCT o.order_id)                                      AS frequency,
        ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) AS monetary
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= '2024-01-01'
      AND o.status = 'Delivered'
    GROUP BY o.customer_id
),

-- ----------------------------------------------------------
-- 2.2 Score each dimension into quintiles (1–5)
-- ----------------------------------------------------------
rfm_scored AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency)          AS f_score,
        NTILE(5) OVER (ORDER BY monetary)           AS m_score
    FROM rfm_base
),

-- ----------------------------------------------------------
-- 2.3 Assign segment labels using CASE WHEN
-- ----------------------------------------------------------
rfm_segmented AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CONCAT(r_score, f_score, m_score)           AS rfm_code,
        CASE
            WHEN r_score >= 4 AND f_score >= 4                  THEN 'Champion'
            WHEN f_score >= 3 AND m_score >= 3                  THEN 'Loyal'
            WHEN r_score <= 2 AND f_score >= 3                  THEN 'At Risk'
            WHEN r_score >= 4 AND f_score <= 2                  THEN 'New Customer'
            ELSE                                                     'Lost'
        END                                         AS segment
    FROM rfm_scored
)

-- ----------------------------------------------------------
-- 2.4 Final output — segment summary
-- ----------------------------------------------------------
SELECT
    segment,
    COUNT(customer_id)          AS customer_count,
    ROUND(AVG(recency_days), 1) AS avg_recency_days,
    ROUND(AVG(frequency), 1)    AS avg_frequency,
    ROUND(AVG(monetary), 2)     AS avg_monetary_value,
    ROUND(SUM(monetary), 2)     AS total_revenue_contribution
FROM rfm_segmented
GROUP BY segment
ORDER BY total_revenue_contribution DESC;
