-- Active: 1790273724970@@127.0.0.1@5432@movielens_elt

\set ON_ERROR_STOP on
\encoding UTF8

CREATE SCHEMA IF NOT EXISTS silver;

CREATE VIEW silver.stg_users AS
    SELECT TRIM(id)::INT AS user_id, TRIM(age)::INT AS age, UPPER(TRIM(gender)) AS gender, TRIM(occupation_id)::INT AS occupation_id,
    TRIM(zip_code) AS zip_code
    FROM bronze.users;

CREATE VIEW silver.stg_movies AS
    SELECT TRIM(id)::INT AS movie_id, TRIM(title) AS title,
    TRIM(release_year)::INT AS release_year
    FROM bronze.movies; 

CREATE VIEW silver.stg_ratings AS
    SELECT TRIM(id)::INT AS rating_id, TRIM(user_id)::INT AS user_id, TRIM(movie_id)::INT AS movie_id,
    TRIM(rating)::NUMERIC(2,1) AS rating, TRIM(rated_at)::TIMESTAMP AS rated_at
    FROM bronze.ratings;

CREATE VIEW silver.stg_occupations AS
    SELECT TRIM(id)::INT AS occupation_id, TRIM(name) AS occupation_name
    FROM bronze.occupations;

CREATE VIEW silver.stg_genres AS
    SELECT TRIM(id)::INT AS genre_id, TRIM(name) AS genre_name
    FROM bronze.genres;

CREATE VIEW silver.stg_genres_movies AS
    SELECT TRIM(id)::INT AS genre_movie_id, TRIM(movie_id):: INT AS movie_id, TRIM(genre_id):: INT AS genre_id
    FROM bronze.genres_movies;

CREATE VIEW silver.stg_age_group AS
    SELECT TRIM(id)::INT AS group_id, TRIM(name) AS name
    FROM bronze.age_group;
