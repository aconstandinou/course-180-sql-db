############################## PRACTICE PROBLEMS ##############################

# 1. Import this file into a database.
1. saved file to 'groupby_aggregate.sql'
2. in CLI, cd over to folder where file exists -> cd launch_school\course_180\schema_data_sql
3. CLI command -> psql -d sql_book < groupby_aggregate.sql

# 2. Write SQL statements that will insert the following films into the database:
INSERT INTO films (title, year, genre, director, duration) VALUES
('Wayne''s World', 1992, 'comedy', 'Penelope Spheeris', 95),
('Bourne Identity', 2002, 'espionage', 'Doug Liman', 118);

# 3. Write a SQL query that lists all genres for which there is a movie in the films table.
SELECT DISTINCT genre FROM films;

# 4. SELECT genre FROM films GROUP BY genre;
SELECT genre FROM films;

# 5. Write a SQL query that determines the average duration across all the movies in the films table, rounded to the nearest minute.
SELECT ROUND(AVG(duration)) FROM films;

# 6. Write a SQL query that determines the average duration for each genre in the films table, rounded to the nearest minute.
SELECT genre, ROUND(AVG(duration)) AS average_duration
  FROM films
GROUP BY genre;

# 7. Write a SQL query that determines the average duration of movies for each decade
#      represented in the films table, rounded to the nearest minute and listed in chronological order.
SELECT movie_decade, AVG(duration)
FROM (
  SELECT year,
  year/10 * 10 as movie_decade,
  duration
  FROM films ) as duration_decades
  GROUP BY movie_decade
  ORDER BY movie_decade;

# LS Answer
SELECT year / 10 * 10 as decade, ROUND(AVG(duration)) as average_duration
  FROM films GROUP BY decade ORDER BY decade;

# 8. Write a SQL query that finds all films whose director has the first name John.
SELECT * FROM films WHERE director SIMILAR TO 'John%';

# 9. Write a SQL query that will return the following data:

genre   | count
-----------+-------
scifi     |     5
comedy    |     4
drama     |     2
espionage |     2
crime     |     1
thriller  |     1
horror    |     1
action    |     1

SELECT genre, count(id)
FROM films
GROUP BY genre
ORDER BY count DESC;

# 10. Write a SQL query that will return the following data:

decade |   genre   |                  films
--------+-----------+------------------------------------------
  1940 | drama     | Casablanca
  1950 | drama     | 12 Angry Men
  1950 | scifi     | 1984
  1970 | crime     | The Godfather
  1970 | thriller  | The Conversation
  1980 | action    | Die Hard
  1980 | comedy    | Hairspray
  1990 | comedy    | Home Alone, The Birdcage, Waynes World
  1990 | scifi     | Godzilla
  2000 | espionage | Bourne Identity
  2000 | horror    | 28 Days Later
  2010 | espionage | Tinker Tailor Soldier Spy
  2010 | scifi     | Midnight Special, Interstellar, Godzilla

SELECT year / 10 * 10 AS decade, genre, string_agg(title, ', ') AS films
  FROM films
GROUP BY decade, genre
ORDER BY decade, genre;

# 11. Write a SQL query that will return the following data:

genre   | total_duration
-----------+----------------
horror    |            113
thriller  |            113
action    |            132
crime     |            175
drama     |            198
espionage |            245
comedy    |            407
scifi     |            632

SELECT genre, SUM(duration) AS total_duration
FROM films
GROUP BY genre
ORDER BY total_duration;
