# 1
(within cli)
$ createdb residents

# 2
# saved file into a folder
# cd into folder
$ psql -d residents < residents_with_data.sql

# 3
SELECT state, COUNT(id) FROM people GROUP BY state ORDER BY count DESC LIMIT 10;

# 4
SELECT DISTINCT(SUBSTRING(email, '\@(.*)')) AS domain, COUNT(id)
FROM people GROUP BY domain ORDER BY count DESC;

# 5
DELETE FROM people WHERE id = 3399

# 6
ERROR: here I had to set client encoding to UTF8 as follows
residents=# SET client_encoding = 'UTF8';
DELETE FROM people WHERE state = 'CA';

# 7
UPDATE people SET given_name = UPPER(given_name)
WHERE SUBSTRING(email, '\@(.*)') = 'teleworm.us';

# 8
DELETE FROM people;
