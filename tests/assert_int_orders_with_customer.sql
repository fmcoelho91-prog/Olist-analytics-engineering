select
    order_id,
    count(*) as occurrences

from {{ ref('int_orders_with_customer') }}

group by order_id

having count(*) > 1