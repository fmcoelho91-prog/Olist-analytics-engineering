with category_metrics as (

    select
        p.product_category_name_english as product_category,
        count(*) as items_sold,
        sum(oi.price) as total_revenue,
        avg(oi.price) as avg_item_price

    from {{ ref('fct_order_items') }} oi

    left join {{ ref('dim_products') }} p
        on oi.product_id = p.product_id

    where p.product_category_name_english is not null

    group by
        p.product_category_name_english

),

ranked as (

    select
        *,
        row_number() over (
            order by total_revenue desc
        ) as revenue_rank

    from category_metrics

)

select
    revenue_rank,
    product_category,
    items_sold,
    total_revenue,
    avg_item_price

from ranked

where revenue_rank <= 10

order by revenue_rank
