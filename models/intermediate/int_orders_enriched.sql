with orders as (

    select *
    from {{ ref('stg_orders') }}

),

order_items as (

    select *
    from {{ ref('int_order_items_aggregated') }}

),

order_payments as (

    select *
    from {{ ref('int_order_payments_aggregated') }}

),

joined as (

    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        oi.item_count,
        oi.total_item_value,
        oi.total_freight_value,

        op.payment_count,
        op.total_payment_value,
        op.max_payment_installments

    from orders o

    left join order_items oi
        on o.order_id = oi.order_id

    left join order_payments op
        on o.order_id = op.order_id

)

select *
from joined