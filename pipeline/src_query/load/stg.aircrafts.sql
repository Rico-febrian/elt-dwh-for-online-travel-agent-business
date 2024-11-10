--
--- Query for load data and handling new data (upsert) from db sources into staging schema in DWH
--

INSERT INTO pactravel_staging.aircrafts 
    (aircraft_id, aircraft_name, aircraft_iata, aircraft_icao)

SELECT
    aircraft_id,
    aircraft_name,
    aircraft_iata,
    aircraft_icao

FROM public.aircrafts

-- Handle new data
ON CONFLICT(aircraft_id) 
DO UPDATE SET
    aircraft_name = EXCLUDED.aircraft_name,
    aircraft_iata = EXCLUDED.aircraft_iata,
    aircraft_icao = EXCLUDED.aircraft_icao,

    -- Handle updated timestamp
    updated_at = CASE WHEN 
                        pactravel_staging.aircrafts.aircraft_name <> EXCLUDED.aircraft_name 
                        OR pactravel_staging.aircrafts.aircraft_iata <> EXCLUDED.aircraft_iata
                        OR pactravel_staging.aircrafts.aircraft_icao <> EXCLUDED.aircraft_icao
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        pactravel_staging.aircrafts.updated_at
                END;
                