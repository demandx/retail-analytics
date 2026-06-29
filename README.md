# Retail Sales & Customer Analytics — SQL Project
**Author:** Tauseef Ahmad Khan  
**Tools:** SQL (MySQL/PostgreSQL) · Excel · Power BI · Tableau

## Project Overview
End-to-end retail analytics project analyzing 8,400+ customer records across FY2024. Covers KPI reporting, RFM customer segmentation, product performance, regional analysis, cohort retention, and sales funnel conversion.


## File Structure

retail-analytics-sql/
│
├── schema/
│   └── 01_create_tables.sql        # Database & table definitions
│
├── queries/
│   ├── 02_kpi_metrics.sql          # Revenue, margin, AOV, YoY growth
│   ├── 03_rfm_segmentation.sql     # RFM scoring & customer segments
│   ├── 04_product_analysis.sql     # Top 10 products, category breakdown
│   └── 05_regional_cohort.sql      # Regional performance, cohort retention, funnel
│
└── README.md

## Key Analyses

### 1. KPI Metrics (`02_kpi_metrics.sql`)
- Total revenue, active customers, average order value
- Gross margin % calculation
- Monthly revenue & profit trend
- YoY growth using LAG window function

### 2. RFM Segmentation (`03_rfm_segmentation.sql`)
- Recency, Frequency, Monetary scoring using `NTILE(5)`
- Segment labels via `CASE WHEN`: Champion, Loyal, At Risk, New, Lost
- Revenue contribution per segment

### 3. Product Analysis (`04_product_analysis.sql`)
- Top 10 products ranked using `RANK()` window function
- Category-wise revenue with % share using `SUM() OVER()`
- YoY category growth using conditional aggregation

### 4. Regional & Cohort Analysis (`05_regional_cohort.sql`)
- Actual vs target revenue by region with variance %
- Cohort retention heatmap data using `TIMESTAMPDIFF`
- Sales funnel conversion using `FIRST_VALUE` and `LAG`



## SQL Concepts Demonstrated
| Concept | Used In |

| CTEs (WITH clause) | RFM, Regional, Funnel |
| Window Functions (RANK, NTILE, LAG, FIRST_VALUE) | KPI, RFM, Product, Funnel |
| Conditional Aggregation (CASE WHEN inside SUM) | YoY Growth |
| JOINs (INNER, multiple tables) | All queries |
| Date Functions (DATEDIFF, TIMESTAMPDIFF, DATE_FORMAT) | KPI, Cohort |
| Subqueries & Nested CTEs | RFM Scoring |


## Dashboard
Interactive HTML dashboard (Power BI + Tableau equivalent) also available in this repo — open `dashboard.html` in any browser.
