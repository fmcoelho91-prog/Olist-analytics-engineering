select
    count(*) as total_items,
    count(p.product_category_name_english) as items_with_english_category,
    count(*) - count(p.product_category_name_english) as items_without_english_category
from {{ ref('fct_order_items') }} oi
left join {{ ref('dim_products') }} p
    on oi.product_id = p.product_id