-- Data Warehouse Staging Schema

-- Create UUID extension if not exist yet
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the schema if not exist yet
CREATE SCHEMA IF NOT EXISTS pactravel_staging AUTHORIZATION postgres;


-- CREATE TABLE AND ITS CONSTRAINTS FOR THE STAGING SCHEMA

CREATE TABLE pactravel_staging.aircrafts (
	aircraft_name varchar NULL,
	aircraft_iata varchar NULL,
	aircraft_icao varchar NULL,
	aircraft_id varchar NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraft_id)
);


CREATE TABLE pactravel_staging.airlines (
	airline_id int4 NOT NULL,
	airline_name varchar NULL,
	country varchar NULL,
	airline_iata varchar NULL,
	airline_icao varchar NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT airlines_pkey PRIMARY KEY (airline_id)
);


CREATE TABLE pactravel_staging.airports (
	airport_id int4 NOT NULL,
	airport_name varchar NULL,
	city varchar NULL,
	latitude float8 NULL,
	longitude float8 NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT airports_pkey PRIMARY KEY (airport_id)
);


CREATE TABLE pactravel_staging.customers (
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


CREATE TABLE pactravel_staging.hotel (
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


CREATE TABLE pactravel_staging.flight_bookings (
	flight_booking_id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
	flight_booking_date date NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT flight_bookings_pkey PRIMARY KEY (flight_booking_id),
	CONSTRAINT unique_trip_flight_seat UNIQUE (trip_id, flight_number, seat_number),
	CONSTRAINT fk_flight_aircraft FOREIGN KEY (aircraft_id) REFERENCES pactravel_staging.aircrafts(aircraft_id),
	CONSTRAINT fk_flight_airline FOREIGN KEY (airline_id) REFERENCES pactravel_staging.airlines(airline_id),
	CONSTRAINT fk_flight_airport_dst FOREIGN KEY (airport_dst) REFERENCES pactravel_staging.airports(airport_id),
	CONSTRAINT fk_flight_airport_src FOREIGN KEY (airport_src) REFERENCES pactravel_staging.airports(airport_id),
	CONSTRAINT fk_flight_customer FOREIGN KEY (customer_id) REFERENCES pactravel_staging.customers(customer_id)
);


CREATE TABLE pactravel_staging.hotel_bookings (
	hotel_booking_id uuid DEFAULT uuid_generate_v4() NOT NULL,
	trip_id int4 NOT NULL,
	customer_id int4 NULL,
	hotel_id int4 NULL,
	check_in_date date NULL,
	check_out_date date NULL,
	price int4 NULL,
	breakfast_included varchar(10) NULL,
	hotel_booking_date date NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT hotel_bookings_pkey PRIMARY KEY (hotel_booking_id),
	CONSTRAINT unique_trip_id UNIQUE (trip_id),
	CONSTRAINT fk_hotel_booking_customer FOREIGN KEY (customer_id) REFERENCES pactravel_staging.customers(customer_id),
	CONSTRAINT fk_hotel_booking_hotel FOREIGN KEY (hotel_id) REFERENCES pactravel_staging.hotel(hotel_id)
);