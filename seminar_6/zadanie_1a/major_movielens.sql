CREATE TABLE dim_users (
    user_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_user_id BIGINT NOT NULL UNIQUE,
    age INT,
    age_group VARCHAR(45),
    gender CHAR(1),
    zip_code VARCHAR(255),
    occupation VARCHAR(255),
    usercol VARCHAR(45)
);

CREATE TABLE dim_movies (
    movie_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_movie_id BIGINT NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    release_year CHAR(4)
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY, -- YYYYMMDD
    full_date DATE NOT NULL UNIQUE,
    day_of_month SMALLINT NOT NULL,
    month_number SMALLINT NOT NULL,
    quarter_number SMALLINT NOT NULL,
    year_number SMALLINT NOT NULL
);

CREATE TABLE dim_genres (
    genre_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_genre_id BIGINT NOT NULL UNIQUE,
    genre_name VARCHAR(255) NOT NULL
);

CREATE TABLE bridge_movie_genres (
    movie_key BIGINT NOT NULL REFERENCES dim_movies(movie_key),
    genre_key BIGINT NOT NULL REFERENCES dim_genres(genre_key),
    PRIMARY KEY (movie_key, genre_key)
);

CREATE TABLE fact_ratings (
    rating_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_rating_id BIGINT NOT NULL UNIQUE,
    user_key BIGINT NOT NULL REFERENCES dim_users(user_key),
    movie_key BIGINT NOT NULL REFERENCES dim_movies(movie_key),
    date_key INT NOT NULL REFERENCES dim_date(date_key),
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    rating_count SMALLINT NOT NULL DEFAULT 1 CHECK (rating_count = 1),
    rated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_fact_ratings_user ON fact_ratings(user_key);
CREATE INDEX idx_fact_ratings_movie ON fact_ratings(movie_key);
CREATE INDEX idx_fact_ratings_date ON fact_ratings(date_key);
CREATE INDEX idx_bridge_genre ON bridge_movie_genres(genre_key);