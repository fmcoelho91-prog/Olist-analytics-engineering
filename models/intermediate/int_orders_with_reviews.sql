with orders as (
    select *
    from {{ ref('int_orders_with_customer') }}
),

reviews as (
    select *
    from {{ ref('int_order_reviews_aggregated') }}
),

joined as (
    select
        o.*,
        r.review_count,
        r.avg_review_score
    from orders o
    left join reviews r
        on o.order_id = r.order_id
)

select *
from joined