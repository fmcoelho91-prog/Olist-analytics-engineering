with order_items as (

    select *
    from {{ ref('stg_order_items') }}

)

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
from order_items