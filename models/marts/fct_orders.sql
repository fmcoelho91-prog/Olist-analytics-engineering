with orders as (

    select *
    from {{ ref('int_orders_with_delivery') }}

)

select
    order_id,
    customer_id,

    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    item_count,
    total_item_value,
    total_freight_value,

    payment_count,
    total_payment_value,
    max_payment_installments,

    review_count,
    avg_review_score,

    delivery_delay_days,
    delivery_time_days,
    is_delayed

from orders