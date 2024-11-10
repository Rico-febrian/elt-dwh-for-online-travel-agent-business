-- Truncate all tables in public schema DWH before load data
TRUNCATE TABLE public.aircrafts CASCADE;
TRUNCATE TABLE public.airlines CASCADE;
TRUNCATE TABLE public.airports CASCADE;
TRUNCATE TABLE public.customers CASCADE;
TRUNCATE TABLE public.hotel CASCADE;
TRUNCATE TABLE public.flight_bookings CASCADE;
TRUNCATE TABLE public.hotel_bookings CASCADE;