-- Active: 1790273724970@@127.0.0.1@5432@movielens_elt

\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;

CREATE SCHEMA IF NOT EXISTS gold;

CREATE TABLE IF NOT EXISTS gold.dim_user(
    user_id INT NOT NULL UNIQUE,
    gender CHAR(1) NOT NULL CHECK(gender IN('M','F')),
    zip_code VARCHAR(10),
    age_group VARCHAR(20) NOT NULL,
    occupation VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_movie(
    movie_id INT NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    release_year INT,
    genre_name VARCHAR(200) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_date(
    date_id INT PRIMARY KEY,
    rated_at DATE NOT NULL UNIQUE,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(10) NOT NULL,
    week INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INT NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_time(
    time_id INT PRIMARY KEY,
    rated_time TIME NOT NULL UNIQUE,
    hour INT NOT NULL,
    minute INT NOT NULL,
    second INT NOT NULL,
    time_of_day VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.fact_rating(
    rating_id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES gold.dim_user(user_id),
    movie_id INT NOT NULL REFERENCES gold.dim_movie(movie_id),
    date_id INT NOT NULL REFERENCES gold.dim_date(date_id),
    time_id INT NOT NULL REFERENCES gold.dim_time(time_id),
    rating NUMERIC(2,1) NOT NULL CHECK(rating BETWEEN 1 AND 5),
    rating_count INT NOT NULL,
    rating_percentage INT NOT NULL
);

CREATE INDEX IF NOT EXISTS fact_rating_user_idx ON gold.fact_rating(user_id);
CREATE INDEX IF NOT EXISTS fact_rating_movie_idx ON gold.fact_rating(movie_id);
CREATE INDEX IF NOT EXISTS fact_rating_date_idx ON gold.fact_rating(date_id);
CREATE INDEX IF NOT EXISTS fact_rating_time_idx ON gold.fact_rating(time_id);

TRUNCATE gold.fact_rating, gold.dim_user, gold.dim_movie,
         gold.dim_date, gold.dim_time;

ALTER TABLE gold.dim_time ALTER COLUMN rated_time TYPE TIME
    USING (NULL::TIME);

INSERT INTO gold.dim_user (user_id, gender, zip_code, age_group, occupation)
SELECT u.user_id, u.gender, u.zip_code, COALESCE(a.name, 'unknown'),
       COALESCE(o.occupation_name, 'unknown')
FROM silver.stg_users u
LEFT JOIN silver.stg_age_group a ON a.group_id = u.age
LEFT JOIN silver.stg_occupations o ON o.occupation_id = u.occupation_id;

INSERT INTO gold.dim_movie (movie_id, title, release_year, genre_name)
SELECT m.movie_id, m.title, m.release_year, COALESCE(g.genre_name, 'unknown')
FROM silver.stg_movies m
LEFT JOIN (
    SELECT gm.movie_id, STRING_AGG(DISTINCT g.genre_name, ', ' ORDER BY g.genre_name) AS genre_name
    FROM silver.stg_genres_movies gm
    JOIN silver.stg_genres g ON g.genre_id = gm.genre_id
    GROUP BY gm.movie_id
) g ON g.movie_id = m.movie_id;

INSERT INTO gold.dim_date (date_id, rated_at, day, month, year, day_of_week, day_name, week, month_name, quarter)
SELECT TO_CHAR(d, 'YYYYMMDD')::INT, d,
       EXTRACT(DAY FROM d)::INT, EXTRACT(MONTH FROM d)::INT,
       EXTRACT(YEAR FROM d)::INT, EXTRACT(ISODOW FROM d)::INT,
       TO_CHAR(d, 'FMDay'), EXTRACT(WEEK FROM d)::INT,
       TO_CHAR(d, 'FMMonth'), EXTRACT(QUARTER FROM d)::INT
FROM (SELECT DISTINCT rated_at::DATE AS d FROM silver.stg_ratings) dates;

INSERT INTO gold.dim_time (time_id, rated_time, hour, minute, second, time_of_day)
SELECT TO_CHAR(t, 'HH24MISS')::INT, t,
       EXTRACT(HOUR FROM t)::INT, EXTRACT(MINUTE FROM t)::INT,
       EXTRACT(SECOND FROM t)::INT,
       CASE WHEN t < TIME '06:00' THEN 'Night'
            WHEN t < TIME '12:00' THEN 'Morning'
            WHEN t < TIME '18:00' THEN 'Afternoon'
            ELSE 'Evening' END
FROM (SELECT DISTINCT DATE_TRUNC('second', rated_at)::TIME AS t
      FROM silver.stg_ratings) times;

INSERT INTO gold.fact_rating (rating_id, user_id, movie_id, date_id, time_id,
                              rating, rating_count, rating_percentage)
SELECT rating_id, user_id, movie_id,
       TO_CHAR(rated_at, 'YYYYMMDD')::INT,
       TO_CHAR(rated_at, 'HH24MISS')::INT,
       rating, 1, ROUND(rating * 100 / 5)::INT
FROM silver.stg_ratings;

COMMIT;

SELECT (SELECT COUNT(*) FROM silver.stg_ratings) AS silver_count,
       (SELECT COUNT(*) FROM gold.fact_rating) AS gold_count;