-- Data Warehouse Public Schema

-- CREATE TABLE AND ITS CONSTRAINTS FOR THE PUBLIC SCHEMA


CREATE TABLE public.aircrafts (
	aircraft_name varchar NULL,
	aircraft_iata varchar NULL,
	aircraft_icao varchar NULL,
	aircraft_id varchar NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,	
	CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraft_id)
);


CREATE TABLE public.airlines (
	airline_id int4 NOT NULL,
	airline_name varchar NULL,
	country varchar NULL,
	airline_iata varchar NULL,
	airline_icao varchar NULL,
	alias varchar NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT airlines_pkey PRIMARY KEY (airline_id)
);


CREATE TABLE public.airports (
	airport_id int4 NOT NULL,
	airport_name varchar NULL,
	city varchar NULL,
	latitude float8 NULL,
	longitude float8 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT airports_pkey PRIMARY KEY (airport_id)
);


CREATE TABLE public.customers (
	customer_id int4 NOT NULL,
	customer_first_name varchar NULL,
	customer_family_name varchar NULL,
	customer_gender varchar NULL,
	customer_birth_date date NULL,
	customer_country varchar NULL,
	customer_phone_number int8 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,	
	CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
);


CREATE TABLE public.hotel (
	hotel_id int4 NOT NULL,
	hotel_name varchar NULL,
	hotel_address varchar NULL,
	city varchar NULL,
	country varchar NULL,
	hotel_score float8 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id)
);


CREATE TABLE public.flight_bookings (
	trip_id int4 NOT NULL,
	customer_id int4 NULL,
	flight_number varchar(32) NOT NULL,
	airline_id int4 NULL,
	aircraft_id varchar(32) NULL,
	airport_src int4 NULL,
	airport_dst int4 NULL,
	departure_time time NULL,
	departure_date date NULL,
	flight_duration varchar(32) NULL,
	travel_class varchar(32) NULL,
	seat_number varchar(32) NOT NULL,
	price int4 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT flight_bookings_pkey PRIMARY KEY (trip_id, flight_number, seat_number),
	CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraft_id) REFERENCES public.aircrafts(aircraft_id),
	CONSTRAINT fk_flight_airline FOREIGN KEY (airline_id) REFERENCES public.airlines(airline_id),
	CONSTRAINT fk_flight_airport_dst FOREIGN KEY (airport_dst) REFERENCES public.airports(airport_id),
	CONSTRAINT fk_flight_airport_src FOREIGN KEY (airport_src) REFERENCES public.airports(airport_id),
	CONSTRAINT fk_flight_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id)
);


CREATE TABLE public.hotel_bookings (
	trip_id int4 NOT NULL,
	customer_id int4 NULL,
	hotel_id int4 NULL,
	check_in_date date NULL,
	check_out_date date NULL,
	price int4 NULL,
	breakfast_included bool NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT hotel_bookings_pkey PRIMARY KEY (trip_id),
	CONSTRAINT fk_hotel_booking_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id),
	CONSTRAINT fk_hotel_booking_hotel FOREIGN KEY (hotel_id) REFERENCES public.hotel(hotel_id)
);