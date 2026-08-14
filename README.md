# Olist E-Commerce Capstone Analysis

**An end-to-end business intelligence project on a 99K-order Brazilian e-commerce marketplace — uncovering why customer satisfaction hinges on delivery speed, and where the business is over-concentrated geographically. Built from 8 raw CSV files to a 7-table normalized PostgreSQL database to an interactive Tableau dashboard and narrative story.**

🔗 **[Live Interactive Dashboard](#)** *(https://public.tableau.com/app/profile/rakes.dey/viz/OlistE-CommerceAnalysisLateDeliveryCutsCustomerRatingsFrom4_2to1_7/Dashboard1?publish=yes)*





🔗 **[Live Story Walkthrough](#)** *(https://public.tableau.com/app/profile/rakes.dey/viz/OlistE-CommerceAnalysisLateDeliveryCutsCustomerRatingsFrom4_2to1_7/Story1)*

---

## Business Problem

Olist is a Brazilian e-commerce marketplace connecting small businesses to major online marketplaces. With order, payment, review, and logistics data spread across 8 separate files, the business needed a single source of truth to answer: **what drives revenue, what drives customer satisfaction, and where is the business exposed to risk?**

---

## Dataset

- **Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle)
- **Scale:** 99,441 orders, 112,650 order line items, 103,886 payments, 99,224 reviews, 3,095 sellers, ~99K customers — Sept 2016 to Oct 2018
- **Structure:** 8 relationally linked CSV files (orders, order items, payments, reviews, customers, products, sellers, category translations)

---

## Tools & Tech Stack

| Stage | Tools |
|---|---|
| Data Cleaning & Wrangling | Python (pandas, numpy), Jupyter Notebook |
| Database | PostgreSQL, psycopg2 |
| Analysis | SQL (CTEs, window functions, multi-table JOINs, aggregation) |
| Visualization | Tableau Public (Interactive Dashboard + Story) |

---

## Approach

### 1. Data Audit & ER Mapping
Before writing any code, I mapped the relationships across all 8 files and validated row-level assumptions rather than trusting column names at face value. This surfaced two critical issues before they could silently corrupt the analysis:

- **Missing payment/review records:** `orders` contains 99,441 unique orders, but `payments` only covers 99,440 and `reviews` only 98,673 — meaning a naive `INNER JOIN` would have silently dropped real orders from every downstream analysis. All joins to these tables use `LEFT JOIN` to preserve every order.
- **`customer_id` is order-scoped, not person-scoped:** Olist assigns a new `customer_id` to every order, even for repeat customers. The dataset separately provides `customer_unique_id`, which persists across a person's orders. An early version of my repeat-purchase analysis grouped by `customer_id` and incorrectly showed a 100% one-time-buyer rate — the bug was caught, and the corrected query (grouping by `customer_unique_id`) revealed the true repeat-purchase rate of 3.12%.

### 2. Database Design (PostgreSQL)
Designed a **7-table normalized schema** — customers, sellers, products, orders, order_items, payments, and reviews — using composite primary keys on `order_items`, `payments`, and `reviews`, since each of those tables can legitimately contain multiple rows per order (multiple products, split payments, or multiple review entries).

- Staging table + `COPY` bulk load pattern for each table, loaded in FK-dependency order (parent tables first, then `orders`, then child tables)
- Foreign key constraints + indexes on all join/filter columns
- Verified referential integrity and row-count consistency against the source CSVs after every load

### 3. SQL Analysis
Wrote a full analysis query set covering:
- Business-wide KPIs (revenue, orders, delivery success rate)
- Multi-table JOINs for revenue by category and state
- `CASE`-based delivery delay bucketing, joined against review scores
- CTE-based repeat-purchase rate analysis (corrected for the `customer_id` scoping issue above)
- Seller-level late-delivery rate ranking
- Payment method distribution


See [`SQL/analysis_queries.sql`](SQL/analysis_queries.sql) for the full query set, including an inline note on the repeat-buyer query correction.

### 4. Data Export & a Join Fan-Out Bug
When exporting a flat, analysis-ready file for Tableau, my first version joined `payments` and `reviews` directly onto the order-item-level data. Because some orders have multiple payment rows (split payments) and multiple review rows, this **multiplied ("fanned out") the order value for any order with more than one payment or review row** — inflating total revenue by roughly 5% ($14.27M reported vs. the true $13.59M confirmed independently in SQL).

I diagnosed this by comparing a simple `SUM(price)` query against the export file's total and tracing the gap to orders with duplicate payment rows. The fix: pre-aggregate `payments` and `reviews` into one row per order using CTEs *before* joining them to the order-level data, eliminating the row multiplication entirely.

### 5. Dashboard & Story (Tableau)
- Built an **interactive dashboard** with a category filter (dropdown), KPI cards, a revenue trend, and drill-down charts
- Built a **4-point narrative story** for stakeholder presentation

---

## Key Findings

**1. Delivery speed is the single biggest driver of customer satisfaction**

| Delivery Bucket | Avg. Review Score |
|---|---|
| Very Early (7+ days) | 4.23 |
| Early | ~4.1 |
| On Time | ~4.0 |
| Late (1–7 days) | ~2.7 |
| Very Late (7+ days) | 1.70 |

Orders that arrive very late score, on average, **more than 2x lower** than orders that arrive very early — a stronger and more consistent pattern than price, category, or payment method showed in the same analysis.

**2. Revenue is heavily concentrated in one state**
São Paulo (SP) alone accounts for **$5.2M of the $13.6M total revenue** — nearly 40% of the entire marketplace, representing a geographic concentration risk.

**3. Only 3.12% of customers are repeat buyers**
Of ~96,000 unique customers, the overwhelming majority (96.88%) made only a single purchase. For a marketplace, this signals a significant retention gap and a heavy reliance on new-customer acquisition.

**4. The business scaled rapidly**
Monthly revenue grew from near-zero in the platform's earliest months to a peak of over $9M/month, reflecting Olist's rapid marketplace growth through 2017–2018.

**5. Delivery performance is strong overall**
97.8% of orders were successfully delivered — the satisfaction problem lies specifically with the *timing* of delivery, not delivery failure itself.

---

## Recommendation

Prioritize logistics and carrier reliability to reduce late deliveries — this is the clearest, most consistent lever available to improve customer satisfaction. In parallel, invest in seller recruitment and marketing outside São Paulo to reduce geographic concentration risk, and explore retention programs given the low repeat-purchase rate.

---

## Repository Structure
```
ecommerce-capstone-analysis/
├── README.md
├── Notebooks/
│   └── data_cleaning_and_export.ipynb
├── SQL/
│   ├── schema.sql
│   └── analysis_queries.sql
├── images/
│   └── interactive_dashboard_screenshot.png
└── Data/
    └── (sample rows only — full dataset via Kaggle link above)
```

---

## What I'd Do With More Time
- Build a Python ETL script (not just a notebook) to automate reloading fresh data exports end-to-end
- Model the revenue impact of reducing late deliveries by X%, to quantify the recommendation
- Investigate *why* São Paulo is so dominant — seller density vs. demand density — to sharpen the diversification recommendation
- Design a simple retention campaign analysis using the repeat vs. one-time buyer segmentation already built