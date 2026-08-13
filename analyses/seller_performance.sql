with seller_metrics as (

    select
        oi.seller_id,
        count(*) as items_sold,
        count(distinct oi.order_id) as orders,
        sum(oi.price) as total_revenue,
        avg(oi.price) as avg_item_price

    from {{ ref('fct_order_items') }} oi

    group by
        oi.seller_id

),

ranked as (

    select
        *,
        row_number() over (
            order by total_revenue desc
        ) as revenue_rank

    from seller_metrics

)

select
    revenue_rank,
    seller_id,
    items_sold,
    orders,
    total_revenue,
    avg_item_price

from ranked

where revenue_rank <= 10

order by revenue_rank