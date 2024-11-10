with dim_date as (
    select *
    from {{ ref("dim_date") }}
), 

stg_flight_bookings as (
    select *
    from {{ ref("stg_pactravel__flight_bookings") }}
),

stg_hotel_bookings as (
    select *
    from {{ ref("stg_pactravel__hotel_bookings") }}
),

hotel_revenue as (
    select 
        date_trunc('day', shb.hotel_booking_date) as hotel_booking_date,
        sum(shb.price) as hotel_daily_revenue,
        count(shb.hotel_booking_id) as hotel_total_booking 
    from 
        stg_hotel_bookings shb
    group by 1
),
flight_revenue as (
    select 
        date_trunc('day', sfb.flight_booking_date) as flight_booking_date,
        sum(sfb.price) as flight_daily_revenue,
        count(sfb.flight_booking_id) as flight_total_booking
    from 
        stg_flight_bookings sfb
    group by 1
),
daily_revenue as (
    select 
        coalesce(fr.flight_booking_date, hr.hotel_booking_date) as booking_date,
        coalesce(fr.flight_daily_revenue, 0) + coalesce(hr.hotel_daily_revenue, 0) as daily_revenue,
        coalesce(fr.flight_daily_revenue, 0) as flight_daily_revenue,
        coalesce(fr.flight_total_booking, 0) as total_flight_booking,
        coalesce(hr.hotel_daily_revenue, 0) as hotel_daily_revenue,
        coalesce(hr.hotel_total_booking, 0) as total_hotel_booking
    from 
        flight_revenue fr
    full outer join
        hotel_revenue hr on fr.flight_booking_date = hr.hotel_booking_date
),

fct_daily_revenue as (

    select 
        dd.date_actual as booking_date,
        dr.daily_revenue,
        dr.flight_daily_revenue,
        dr.hotel_daily_revenue,
        dr.total_flight_booking,
        dr.total_hotel_booking,        
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from daily_revenue dr
    join dim_date dd 
        on dd.date_actual = dr.booking_date
)

select * from fct_daily_revenue
