select
    is_delayed,
    count(*) as orders,
    avg(avg_review_score) as avg_review_score
from {{ ref('fct_orders') }}
where avg_review_score is not null
  and is_delayed is not null
group by is_delayed
order by is_delayed