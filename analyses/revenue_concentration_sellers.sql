with seller_revenue as (

    select
        seller_id,
        sum(price) as total_revenue
    from {{ ref('fct_order_items') }}
    group by seller_id

),

ranked as (

    select
        seller_id,
        total_revenue,
        row_number() over (
            order by total_revenue desc
        ) as revenue_rank,

        sum(total_revenue) over () as marketplace_revenue

    from seller_revenue

)

select
    sum(
        case
            when revenue_rank <= 10
            then total_revenue
            else 0
        end
    ) as top_10_seller_revenue,

    max(marketplace_revenue) as total_marketplace_revenue,

    sum(
        case
            when revenue_rank <= 10
            then total_revenue
            else 0
        end
    )
    / max(marketplace_revenue) * 100 as top_10_revenue_pct

from ranked