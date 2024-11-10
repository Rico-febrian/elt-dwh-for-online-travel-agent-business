with dim_date as (
    select *
    from {{ ref("dim_date") }}
), 

dim_customers as (
    select *
    from {{ ref("dim_customers") }}
),

dim_aircrafts as (
    select *
    from {{ ref("dim_aircrafts") }}
),

dim_airlines as (
    select *
    from {{ ref("dim_airlines") }}
),

dim_airports as (
    select *
    from {{ ref("dim_airports") }}
),

stg_flight_bookings as (
    select
		flight_booking_id as nk_flight_booking_id,
		trip_id,
		customer_id,
		flight_number,
		airline_id,
		aircraft_id,
		airport_src,
		airport_dst,
		departure_time,
		departure_date,
		flight_duration,
		travel_class,
		seat_number,
		price,
		flight_booking_date
    from {{ ref("stg_pactravel__flight_bookings") }}
),

fct_flight_bookings as (

    select
        {{ dbt_utils.generate_surrogate_key( ["nk_flight_booking_id"]) }} as sk_flight_booking_id,
        sfb.nk_flight_booking_id as dd_flight_booking_id,
		sfb.trip_id as dd_trip_id,
		sfb.flight_number,
		sfb.seat_number,
		dal.nk_airline_id as airline_id,
		dac.nk_aircraft_id as aircraft_id,
		dap1.airport_name as departure_airport,
		dap2.airport_name as arrival_airport,
		dd2.date_actual as flight_booking_date,
		dd1.date_actual as departure_date,
		sfb.departure_time,
		sfb.flight_duration,
		sfb.travel_class,
		sfb.price as total_price,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    from stg_flight_bookings sfb
    left join dim_customers dc
    	on dc.nk_customer_id = sfb.customer_id
	left join dim_airlines dal
		on dal.nk_airline_id = sfb.airline_id
	left join dim_aircrafts dac
		on dac.nk_aircraft_id = sfb.aircraft_id
	left join dim_airports dap1
		on dap1.nk_airport_id = sfb.airport_src
	left join dim_airports dap2
		on dap2.nk_airport_id = sfb.airport_dst
	left join dim_date dd1
		on dd1.date_actual = sfb.departure_date
	left join dim_date dd2
		on dd2.date_actual = sfb.flight_booking_date
)

select * from fct_flight_bookings
