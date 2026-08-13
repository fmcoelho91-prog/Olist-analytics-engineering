with orders as (

    select *
    from {{ ref('int_orders_enriched') }}

),

customers as (

    select *
    from {{ ref('stg_customers') }}

),

joined as (

    select
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,

        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        o.item_count,
        o.total_item_value,
        o.total_freight_value,

        o.payment_count,
        o.total_payment_value,
        o.max_payment_installments

    from orders o

    left join customers c
        on o.customer_id = c.customer_id

)

select *
from joined