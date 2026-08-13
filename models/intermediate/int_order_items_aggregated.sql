with order_items as (

    select *
    from {{ ref('stg_order_items') }}

),

aggregated as (

    select
        order_id,
        count(*) as item_count,
        sum(price) as total_item_value,
        sum(freight_value) as total_freight_value

    from order_items
    group by order_id

)

select *
from aggregated