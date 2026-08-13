with orders as (

    select *
    from {{ ref('int_orders_with_reviews') }}

),

delivery_metrics as (

    select
        *,
        datediff(
            'day',
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) as delivery_delay_days,

        datediff(
            'day',
            order_purchase_timestamp,
            order_delivered_customer_date
        ) as delivery_time_days

    from orders

),

classified as (

    select
        *,
        case
            when delivery_delay_days is null then null
            when delivery_delay_days > 0 then 1
            else 0
        end as is_delayed

    from delivery_metrics

)

select *
from classified