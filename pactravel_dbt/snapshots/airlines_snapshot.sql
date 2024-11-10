{% snapshot airlines_snapshot %}

{{
    config(
        target_database="pactravel-dwh",
        target_schema="pactravel_snapshots",
        unique_key="sk_airline_id",

        strategy="timestamp",
        updated_at="updated_at"
    )
}}

select *
from {{ ref("dim_airlines") }} 

{% endsnapshot %}