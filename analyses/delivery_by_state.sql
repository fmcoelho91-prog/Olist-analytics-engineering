with state_metrics as (

    select
        c.customer_state,

        count(*) as orders,

        avg(o.delivery_time_days) as avg_delivery_time_days,

        avg(o.delivery_delay_days) as avg_delivery_delay_days,

        avg(o.is_delayed) * 100 as delayed_order_pct

    from {{ ref('fct_orders') }} o

    left join {{ ref('dim_customers') }} c
        on o.customer_id = c.customer_id

    where o.delivery_time_days is not null
      and o.is_delayed is not null

    group by
        c.customer_state

),

ranked as (

    select
        *,
        row_number() over (
            order by delayed_order_pct desc
        ) as delay_rank

    from state_metrics

)

select
    delay_rank,
    customer_state,
    orders,
    avg_delivery_time_days,
    avg_delivery_delay_days,
    delayed_order_pct

from ranked

where delay_rank <= 10

order by delay_rank