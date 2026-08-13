select
    order_id,
    delivery_delay_days,
    is_delayed
from {{ ref('fct_orders') }}
where is_delayed = 1
  and delivery_delay_days <= 0