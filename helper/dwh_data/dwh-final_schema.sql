-- Data Warehouse Final Schema

-- Create UUID extension if not exist yet
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the schema if not exist yet
CREATE SCHEMA IF NOT EXISTS pactravel_final AUTHORIZATION postgres;