########################### Table and Column Aliases ###########################

- using the 'AS' keyword to rename something in the DB or schema.

- example DB in video -> two tables: directors and films.

###################### Scenario 1: Rename column selected ######################

SELECT title AS name, year AS released_on FROM films;

name                        | released_on
----------------------------+------------
Die HArd                    |        1988

###################### Scenario 2: Rename column, joining tables ###############

SELECT * FROM films INNER JOIN directors ON films.director_id = directors.id;

- this resulted in duplicate columns, director_id and id

SELECT title, name, films.id AS filmd_id, director_id FROM films INNER JOIN directors ON films.director_id = directors.id;

###################### Scenario 3: change name table within query ##############

SELECT * FROM films AS f;

- resulted in no issue (identical to previous query of selecting all columns)
- lets try renaming some columns, within the same type of query

SELECT films.title, films.year FROM films AS f;

- resulted in an error: Perhaps you meant to reference the table alias "f".
- when we tell PostgreSQL to alias our data to 'AS' f, we need to refer to the data
  inside that table f with f.

SELECT f.title, f.year FROM films AS f;

###################### Scenario 4: diminishing query length by aliasing tables #

SELECT f.title, d.name, f.id AS film_id, f.director_id
  FROM films AS f
INNER JOIN directors AS d
   ON f.director_id = d.id;

###################### Scenario 5: rename aggregate function ###################

- PostgreSQL takes the last function applied to a column as the return col. name

SELECT COUNT(id) FROM films;

count
-----
   10

SELECT COUNT(id) AS total_films, COUNT(DISTINCT director_id) AS total_directors FROM films;

total_films | total_directors
------------+----------------
         10 |               8

- this becomes more precise, and less ambiguous.
