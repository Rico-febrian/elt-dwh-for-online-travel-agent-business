--
--- Query for load data and handling new data (upsert) from db sources into staging schema in DWH
--

INSERT INTO pactravel_staging.airports
    (airport_id, airport_name, city, latitude, longitude)

SELECT
    airport_id,
    airport_name,
    city,
    latitude,
    longitude

FROM public.airports

-- Handle new data
ON CONFLICT(airport_id) 
DO UPDATE SET
    airport_name = EXCLUDED.airport_name,
    city = EXCLUDED.city,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,

    -- Handle updated timestamp
    updated_at = CASE WHEN 
                        pactravel_staging.airports.airport_name <> EXCLUDED.airport_name 
                        OR pactravel_staging.airports.city <> EXCLUDED.city
                        OR pactravel_staging.airports.latitude <> EXCLUDED.latitude
                        OR pactravel_staging.airports.longitude <> EXCLUDED.longitude
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        pactravel_staging.airports.updated_at
                END;
