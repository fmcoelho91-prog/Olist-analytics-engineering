with reviews as (

    select *
    from {{ ref('stg_order_reviews') }}

),

aggregated as (

    select
        order_id,
        count(*) as review_count,
        avg(review_score) as avg_review_score

    from reviews
    group by order_id

)

select *
from aggregated