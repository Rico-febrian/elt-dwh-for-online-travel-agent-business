--
--- Query for load data and handling new data (upsert) from db sources into staging schema in DWH
--

INSERT INTO pactravel_staging.airlines
    (airline_id, airline_name, country, airline_iata, airline_icao)

SELECT
    airline_id,
    airline_name,
    country,
    airline_iata,
    airline_icao

FROM public.airlines

-- Handle new data
ON CONFLICT(airline_id) 
DO UPDATE SET
    airline_name = EXCLUDED.airline_name,
    country = EXCLUDED.country,
    airline_iata = EXCLUDED.airline_iata,
    airline_icao = EXCLUDED.airline_icao,

    -- Handle updated timestamp
    updated_at = CASE WHEN 
                        pactravel_staging.airlines.airline_name <> EXCLUDED.airline_name 
                        OR pactravel_staging.airlines.country <> EXCLUDED.country
                        OR pactravel_staging.airlines.airline_iata <> EXCLUDED.airline_iata
                        OR pactravel_staging.airlines.airline_icao <> EXCLUDED.airline_icao
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        pactravel_staging.airlines.updated_at
                END;
