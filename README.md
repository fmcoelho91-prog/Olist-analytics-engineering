# Modern E-Commerce Analytics Platform

## Overview

This project demonstrates the design and implementation of a modern analytics engineering workflow using Snowflake and dbt on the Brazilian Olist e-commerce dataset.

The objective was to transform raw transactional data into a clean, tested and documented analytical model that supports reliable business analysis across orders, customers, products, sellers, payments, reviews and delivery performance.

The project follows a layered architecture:

- Raw data stored in Snowflake
- Staging models for standardization and data quality
- Intermediate models for aggregation and business logic
- Dimensional marts for analytics and reporting

---

## Tech Stack

- Snowflake
- dbt Cloud
- SQL
- Git / GitHub
- Power BI (planned final analytical layer)

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

Joining these tables directly would create fanout and potentially inflate analytical metrics.

---

## Staging Layer

The staging layer standardizes the raw data while preserving the original grain of each source table.

Examples:

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

Contains seller geographic attributes.

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

---

## Business Analysis Opportunities

The analytical model can support questions such as:

- How does delivery delay affect customer review scores?
- Which product categories generate the most revenue?
- Which sellers generate the highest sales volume?
- Which customer regions generate the most orders?
- How do freight costs vary by product category?
- Which sellers or categories are associated with longer delivery times?

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



---

## Next Steps

- Build the final Power BI analytical layer
- Analyze delivery performance versus customer satisfaction
- Add visual documentation of the dbt lineage
- Create final business insights and recommendations
