# 1. A.
Creates a table titled "films" with three columns title, year, genre
The file then loads three rows of data.
The file contains SQL statements, when imported the statements are executed.

# 1. B.
1 - NOTICE: table "films" does not exist, skipping
2 - DROP TABLE
3 - CREATE TABLE
4 - INSERT 0 1
5 - INSERT 0 1
6 - INSERT 0 1

Line 1: DROP TABLE will remove a table. The IF EXISTS parameter is used to avoid an error.
Line 2: there is no table called `films` in the database so this command is skipped
Line 3: Creates a table
Line 4/5/6: This is the return value when a row is added to our table.

# 1. C.
DROP TABLE will remove a table. The IF EXISTS parameter is used to avoid an error.

# 2.
SELECT * FROM films;

# 3.
SELECT * FROM films WHERE length(title) < 12;

# 4.
ALTER TABLE films ADD COLUMN director varchar(255);
ALTER TABLE films ADD COLUMN duration integer;

# 5.
UPDATE films
   SET director = 'John McTiernan', duration = 132
 WHERE title = 'Die Hard';

UPDATE films
  SET director = 'Michael Curtiz', duration = 102
WHERE title = 'Casablanca';

UPDATE films
   SET director = 'Francis Ford Coppola', duration = 113
 WHERE title = 'The Conversation';

# 6.

INSERT INTO films (title, year, genre, director, duration) VALUES
('1984', 1956, 'scifi', 'Michael Anderson', 90),
('Tinker Tailor Soldier Spy', 2011, 'espionage', 'Tomas Alfredson', 127),
('The Birdcage', 1996, 'comedy', 'Mike Nichols', 118);

# 7.
SELECT title, extract(year from current_date) - year AS age
FROM films ORDER BY age ASC;

# 8.

SELECT title, duration FROM films
WHERE duration > 120 ORDER BY duration DESC;

# 9.

SELECT title FROM films
ORDER BY duration DESC LIMIT 1;
