--
--- Query for load data and handling new data (upsert) from db sources into staging schema in DWH
--

INSERT INTO pactravel_staging.customers
    (customer_id, customer_first_name, customer_family_name, customer_gender, customer_birth_date, customer_country, customer_phone_number)

SELECT
    customer_id,
    customer_first_name,
    customer_family_name,
    customer_gender,
    customer_birth_date,
    customer_country,
    customer_phone_number

FROM public.customers

-- Handle new data
ON CONFLICT(customer_id)
DO UPDATE SET
    customer_first_name = EXCLUDED.customer_first_name,
    customer_family_name = EXCLUDED.customer_family_name,
    customer_gender = EXCLUDED.customer_gender,
    customer_birth_date = EXCLUDED.customer_birth_date,
    customer_country = EXCLUDED.customer_country,
    customer_phone_number = EXCLUDED.customer_phone_number,

    -- Handle updated timestamp
    updated_at = CASE WHEN 
                        pactravel_staging.customers.customer_first_name <> EXCLUDED.customer_first_name
                        OR pactravel_staging.customers.customer_family_name <> EXCLUDED.customer_family_name
                        OR pactravel_staging.customers.customer_gender <> EXCLUDED.customer_gender
                        OR pactravel_staging.customers.customer_birth_date <> EXCLUDED.customer_birth_date
                        OR pactravel_staging.customers.customer_country <> EXCLUDED.customer_country
                        OR pactravel_staging.customers.customer_phone_number <> EXCLUDED.customer_phone_number
                THEN
                        CURRENT_TIMESTAMP
                ELSE
                        pactravel_staging.customers.updated_at
                END;
