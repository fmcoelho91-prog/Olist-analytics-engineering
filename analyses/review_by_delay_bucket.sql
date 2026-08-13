select
    case
        when delivery_delay_days <= 0 then 'On time / Early'
        when delivery_delay_days between 1 and 3 then '1-3 days late'
        when delivery_delay_days between 4 and 7 then '4-7 days late'
        when delivery_delay_days between 8 and 14 then '8-14 days late'
        when delivery_delay_days > 14 then '15+ days late'
    end as delay_bucket,

    count(*) as orders,
    avg(avg_review_score) as avg_review_score

from {{ ref('fct_orders') }}

where avg_review_score is not null
  and delivery_delay_days is not null

group by 1
order by
    case delay_bucket
        when 'On time / Early' then 1
        when '1-3 days late' then 2
        when '4-7 days late' then 3
        when '8-14 days late' then 4
        when '15+ days late' then 5
    end