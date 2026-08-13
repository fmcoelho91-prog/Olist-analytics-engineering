select
    order_id,
    order_estimated_delivery_date,
    order_delivered_customer_date,
    delivery_delay_days,
    is_delayed
from {{ ref('int_orders_with_delivery') }}
where order_delivered_customer_date is not null