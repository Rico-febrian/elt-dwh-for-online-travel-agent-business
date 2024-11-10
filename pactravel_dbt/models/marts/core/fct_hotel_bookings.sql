with dim_date as (
    select *
    from {{ ref("dim_date") }}
), 

dim_customers as (
    select *
    from {{ ref("dim_customers") }}
),

dim_hotel as (
    select *
    from {{ ref("dim_hotel") }}
),

aggregation as (
    select
        trip_id,
        check_in_date,
        check_out_date,
        (check_out_date - check_in_date) as total_days_stay
    from {{ ref("stg_pactravel__hotel_bookings") }}
    group by 1, 2, 3
),

stg_hotel_bookings as (
    select
        hotel_booking_id as nk_hotel_booking_id,
        trip_id,
        customer_id,
        hotel_id,
        check_in_date,
        check_out_date,
        price,
        breakfast_included,
        hotel_booking_date
    from {{ ref("stg_pactravel__hotel_bookings") }}
),

fct_hotel_bookings as (

    select
        {{ dbt_utils.generate_surrogate_key( ["shb.nk_hotel_booking_id"]) }} as sk_hotel_booking_id,
        shb.nk_hotel_booking_id as dd_hotel_booking_id,
        shb.trip_id as dd_trip_id,
        dh.nk_hotel_id as hotel_id,
        dd3.date_actual as hotel_booking_date,
        dd1.date_actual as check_in_date,
        dd2.date_actual as check_out_date,
        shb.breakfast_included,
        agg.total_days_stay,
        shb.price as total_amount,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from stg_hotel_bookings shb
    left join dim_customers dc
        on dc.nk_customer_id = shb.customer_id
    left join dim_hotel dh
        on dh.nk_hotel_id = shb.hotel_id
    left join aggregation agg
        on agg.trip_id = shb.trip_id
    left join dim_date dd1
        on dd1.date_actual = shb.check_in_date
    left join dim_date dd2
        on dd2.date_actual = shb.check_out_date
    left join dim_date dd3
        on dd3.date_actual = shb.hotel_booking_date
)

select * from fct_hotel_bookings
