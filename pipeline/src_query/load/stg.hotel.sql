--
--- Query for load data and handling new data (upsert) from db sources into staging schema in DWH
--

INSERT INTO pactravel_staging.hotel
    (hotel_id, hotel_name, hotel_address, city, country, hotel_score)

SELECT
    hotel_id,
    hotel_name,
    hotel_address,
    city,
    country,
    hotel_score

FROM public.hotel

-- Handle new data
ON CONFLICT(hotel_id)
DO UPDATE SET
    hotel_name = EXCLUDED.hotel_name,
    hotel_address = EXCLUDED.hotel_address,
    city = EXCLUDED.city,
    country = EXCLUDED.country,
    hotel_score = EXCLUDED.hotel_score,

    -- Handle updated timestamp
    updated_at = CASE WHEN 
                        pactravel_staging.hotel.hotel_name <> EXCLUDED.hotel_name
                        OR pactravel_staging.hotel.hotel_address <> EXCLUDED.hotel_address
                        OR pactravel_staging.hotel.city <> EXCLUDED.city
                        OR pactravel_staging.hotel.country <> EXCLUDED.country
                        OR pactravel_staging.hotel.hotel_score <> EXCLUDED.hotel_score
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        pactravel_staging.hotel.updated_at
                END;
