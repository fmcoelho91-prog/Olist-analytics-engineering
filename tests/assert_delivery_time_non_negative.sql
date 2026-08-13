select
    order_id,
    delivery_time_days
from {{ ref('fct_orders') }}
where delivery_time_days < 0