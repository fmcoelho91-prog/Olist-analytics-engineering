# Modern E-Commerce Analytics Platform

## Overview

This project demonstrates the design and implementation of a modern analytics engineering workflow using **Snowflake** and **dbt** on the Brazilian Olist e-commerce dataset.

The objective was to transform raw transactional data into a clean, tested, documented and analysis-ready dimensional model that supports reliable business analysis across orders, customers, products, sellers, payments, reviews and delivery performance.

The project follows a layered architecture:

- Raw data stored in Snowflake
- Staging models for standardization and data quality
- Intermediate models for aggregation and business logic
- Dimensional marts for analytics
- Final analytical SQL queries for business insights

---

## Tech Stack

- Snowflake
- dbt Cloud
- SQL
- Git / GitHub

---

## Dataset

The project uses the public Brazilian E-Commerce dataset by Olist.

The source contains 9 relational CSV files covering:

- Orders
- Order Items
- Payments
- Customers
- Products
- Sellers
- Reviews
- Geolocation
- Product Category Translation

---

## Architecture

The transformation workflow follows a layered dbt architecture:

RAW
↓
STAGING
↓
INTERMEDIATE
↓
MARTS
↓
ANALYSES

### Raw Layer

The original CSV files were loaded into Snowflake without business transformations.

Database:

OLIST_RAW

Schema:

RAW

This layer preserves the original source data.

---

## Data Profiling

Before transformation, the raw tables were profiled to understand:

- row counts
- primary key candidates
- uniqueness
- null values
- table grain
- one-to-many relationships
- potential data quality issues

This step was particularly important because several Olist tables contain multiple records per order.

For example:

- one order can contain multiple items
- one order can contain multiple payment records
- one order can contain multiple reviews

Joining these tables directly would create **fanout** and potentially inflate analytical metrics.

---

## Staging Layer

The staging layer standardizes the raw data while preserving the original grain of each source table.

Models include:

stg_orders  
stg_order_items  
stg_order_payments  
stg_customers  
stg_products  
stg_sellers  
stg_order_reviews  
stg_geolocation  
stg_product_category_translation

The staging layer includes:

- explicit column selection
- standardized naming
- source definitions
- uniqueness tests
- not-null tests
- relationship tests
- accepted value tests

Example source reference:

    select *
    from {{ source('olist_raw', 'orders') }}

---

## Intermediate Layer

The intermediate layer prepares the data for dimensional modeling and prevents incorrect joins.

### Order Items Aggregation

int_order_items_aggregated

Transforms order item data from:

1 row per item

to:

1 row per order

Metrics include:

- item count
- total item value
- total freight value

### Payment Aggregation

int_order_payments_aggregated

Aggregates multiple payment records into one row per order.

Metrics include:

- payment count
- total payment value
- maximum number of installments

### Review Aggregation

int_order_reviews_aggregated

Aggregates multiple review records into one row per order.

Metrics include:

- review count
- average review score

### Orders Enrichment

The order model is progressively enriched with:

- item metrics
- payment metrics
- customer attributes
- review metrics
- delivery metrics

The final intermediate order model maintains the grain:

1 row per order

---

## Fanout Prevention

One of the main modeling challenges in the project was avoiding fanout.

For example, if an order contains:

3 items  
2 payment records

a direct join between both tables could produce:

3 × 2 = 6 rows

This would duplicate measures such as revenue or freight.

To avoid this problem, one-to-many tables are aggregated to the order level before being joined to the order model.

This ensures analytical metrics remain accurate.

---

## Delivery Performance

Delivery performance metrics were added to support customer experience analysis.

### Delivery Delay

delivery_delay_days

Measures the difference between actual and estimated delivery dates.

Interpretation:

Positive value = late delivery  
Zero = delivered on estimated date  
Negative value = delivered early

### Delivery Time

delivery_time_days

Measures the number of days between purchase and customer delivery.

### Delay Flag

is_delayed

Classifies whether an order was delivered after the estimated delivery date.

Orders without an actual delivery date remain unclassified.

---

## Analytical Marts

The final analytical model follows a dimensional structure.

### Fact Tables

#### fct_orders

Grain:

1 row per order

Contains:

- order status
- purchase and delivery timestamps
- item metrics
- payment metrics
- review metrics
- delivery performance metrics

#### fct_order_items

Grain:

1 row per item within an order

Contains:

- product
- seller
- item price
- freight value
- shipping limit date

---

## Dimensions

### dim_customers

Grain:

1 row per customer_id

Contains:

- customer unique identifier
- city
- state
- postal code prefix

### dim_products

Grain:

1 row per product

Contains:

- product category
- English category translation
- product dimensions
- product weight

### dim_sellers

Grain:

1 row per seller

Contains:

- seller city
- seller state
- postal code prefix

---

## Data Quality

Data quality is validated using both generic and singular dbt tests.

Examples include:

- unique order identifiers
- unique customer identifiers
- unique product identifiers
- referential integrity between facts and dimensions
- valid review scores
- non-negative delivery times
- consistency between delivery delay and delayed flag

Example business rule:

    select
        order_id,
        delivery_delay_days,
        is_delayed
    from {{ ref('fct_orders') }}
    where is_delayed = 1
      and delivery_delay_days <= 0

A successful test returns zero rows.

---

## Documentation and Lineage

dbt documentation is generated for the analytical models and their columns.

The project lineage allows the full transformation path to be traced from raw sources through staging and intermediate models to the final marts.

Source  
↓  
Staging  
↓  
Intermediate  
↓  
Fact / Dimension

### dbt Lineage

![dbt lineage](https://github.com/fmcoelho91-prog/Olist-analytics-engineering/blob/main/images/imagesdbt-lineage-overview.png.png)

---

## Deployment

The project includes a dbt Cloud production deployment job.

The production workflow runs:

    dbt build
    dbt docs generate

This validates models and tests while generating metadata for the dbt Catalog.

---

## Key Engineering Decisions

Several modeling decisions were made to improve reliability and maintainability:

- Explicitly define the grain of every model
- Aggregate one-to-many relationships before order-level joins
- Preserve orders without reviews using LEFT JOINs
- Separate order-level and item-level facts
- Separate descriptive attributes into dimensions
- Use dbt tests to enforce data quality and business rules
- Keep transformations modular and easy to explain
- Use Git branches and pull requests for version control
- Validate the project through a production dbt Cloud job

---

## Key Business Insights

The analytical marts were used to answer a set of business questions focused on customer experience, product performance, seller performance and delivery reliability.

### Delivery Delays and Customer Satisfaction

Orders delivered on time or early achieved an average review score of **4.29**, while delayed orders achieved an average score of only **2.27**.

This represents a difference of approximately **2 review points**, showing a strong association between delivery performance and customer satisfaction.

A more detailed analysis by delay duration showed a progressive decline in customer ratings:

- On time / early: 4.29
- 1–3 days late: 3.29
- 4–7 days late: 2.11
- 8–14 days late: 1.67
- 15+ days late: 1.73

The pattern suggests that customer satisfaction deteriorates significantly as delivery delays increase.

---

### Product Category Performance

The highest-revenue product categories were:

1. health_beauty — 1,258,681.34
2. watches_gifts — 1,205,005.68
3. bed_bath_table — 1,036,988.68
4. sports_leisure — 988,048.97
5. computers_accessories — 911,954.32

The results show that revenue is driven by different combinations of sales volume and average item price.

For example, `bed_bath_table` generated high revenue mainly through volume, with more than 11,000 items sold, while `watches_gifts` generated similar revenue with fewer items but a considerably higher average item price.

---

### Seller Performance

The top seller generated approximately **229,473** in revenue across **1,132 orders**.

Seller performance varied between volume-driven and high-ticket strategies.

Some sellers generated high revenue through large numbers of orders, while others achieved similar revenue with fewer transactions and significantly higher average item prices.

---

### Revenue Concentration

The Top 10 sellers generated approximately:

**1,787,241.74**

Total marketplace revenue was approximately:

**13,591,643.70**

The Top 10 sellers therefore represented around:

**13.15% of total marketplace revenue**

This suggests that marketplace revenue is relatively distributed across a broad seller base rather than being heavily concentrated among a small number of sellers.

---

### Delivery Performance by Customer State

Delivery reliability varied considerably by customer location.

Among the states with the highest delayed-order rates:

- AL: 21.41%
- MA: 17.43%
- SE: 15.22%
- PI: 13.87%
- CE: 13.76%

Alagoas showed the highest delayed-order percentage among the analyzed states, with more than one in five delivered orders arriving after the estimated date.

These results suggest that geographic location is an important dimension when evaluating delivery performance and customer experience.

---

## Analytical Queries

The final analytical layer includes reusable SQL analyses covering:

- delivery delay versus review score
- review score by delay duration
- revenue by product category
- seller performance
- delivery performance by customer state
- seller revenue concentration

These queries are stored in the `analyses/` directory and use the final dimensional marts rather than the raw source tables.

---

## Project Structure

models/
│
├── staging/
│   ├── stg_orders.sql
│   ├── stg_order_items.sql
│   ├── stg_order_payments.sql
│   ├── stg_customers.sql
│   ├── stg_products.sql
│   ├── stg_sellers.sql
│   ├── stg_order_reviews.sql
│   ├── stg_geolocation.sql
│   └── stg_product_category_translation.sql
│
├── intermediate/
│   ├── int_order_items_aggregated.sql
│   ├── int_order_payments_aggregated.sql
│   ├── int_orders_enriched.sql
│   ├── int_orders_with_customer.sql
│   ├── int_order_reviews_aggregated.sql
│   ├── int_orders_with_reviews.sql
│   └── int_orders_with_delivery.sql
│
└── marts/
    ├── fct_orders.sql
    ├── fct_order_items.sql
    ├── dim_customers.sql
    ├── dim_products.sql
    └── dim_sellers.sql


analyses/
│
├── delivery_vs_review.sql
├── review_by_delay_bucket.sql
├── revenue_by_product_category.sql
├── seller_performance.sql
├── delivery_by_state.sql
├── revenue_concentration_sellers.sql
└── check_product_categories.sql


tests/
│
├── assert_delivery_time_non_negative.sql
├── assert_delayed_flag_positive_delay.sql
├── assert_non_delayed_flag_non_positive_delay.sql
└── grain / uniqueness validation tests


images/
│
└── dbt lineage screenshots

---

## Future Improvements

Possible future extensions include:

- automated source ingestion
- incremental models for larger datasets
- CI checks for pull requests
- deeper use of the geolocation dataset
- additional operational and customer experience metrics

---

## Project Outcome

The project demonstrates how raw e-commerce data can be transformed into a reliable analytical layer using modern analytics engineering practices.

The final solution combines:

- cloud data warehousing
- modular SQL transformations
- dimensional modeling
- automated data quality testing
- business rule validation
- documentation and lineage
- Git-based development
- production deployment
- reusable analytical queries

The result is an analysis-ready data platform designed for reliable downstream business analytics.
