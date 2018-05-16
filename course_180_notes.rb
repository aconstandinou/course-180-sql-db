--------------------------------- SQL LANGUAGE ---------------------------------

SQL: - language used to manipulate structure and values of datasets stored in relational DBs.
       "special purpose language"
     - predominantly a declarative language (describes what to do not how to do it)
     - SQL server abstracts these details.

SQL = 3 Languages in one
1) DDL (Data Definition Language): relation structure and rules   CREATE, DROP, ALTER
2) DML (Data Manipulation Language): values stored within relations SELECT, INSERT, UPDATE, DELETE  (CRUD)
3) DCL (Data Control Language): who can do what   GRANT

Schema: "structure" of a DB, defined by: - names of tables
                                         - names of table columns
                                         - data type of columns
                                         - any constraints they have
        Uses DDL sub-language, and some parts of DCL

Data: concerned w/ "contents" of DB. These are the actual values associated w/ rows/cols in DB.

-------------------------------- SQL STYLE GUIDE --------------------------------
# https://www.sqlstyle.guide/

# DOs
- consistent/descriptive identifiers/names
- white space/indentation to make code easier to read
- store ISO-8601 compliant time/date info
- include comments where necessary

# /* Updating the file record after writing to the file */
# UPDATE file_system
#   SET file_modified_date = '1980-02-22 13:19:01.00000',
#       file_size = 209732
# WHERE file_name = '.vimrc';

# DONTs
- CamelCase
- descriptive prefixes or Hungarian notation, ie: sp_ or tbl_staff
- plurals (ie, use staff vs employees)

# Query Syntax
- use uppercase for reserved words (ie: SELECT)

# Whitespace
- spaces should be used to line up code so that root keywords all end on the same char boundary.
# right alignment vs left alignment
(SELECT b.species_name,
        AVG(b.height) AS average_height, AVG(b.diameter) AS average_diameter
   FROM botanic_garden_flora AS b
  WHERE b.species_name = 'Banksia'
     OR b.species_name = 'Sheoak'
     OR b.species_name = 'Wattle'
  GROUP BY b.species_name, b.observation_date)

# Indentation

- On JOINs (indented to the other side of the river and grouped with a new line)

SELECT r.last_name
  FROM riders AS r
       INNER JOIN bikes AS b
       ON r.bike_vin_num = b.vin_num
          AND b.engines > 2

       INNER JOIN crew AS c
       ON r.crew_chief_last_name = c.last_name
          AND c.chief = 'Y';

- On Subqueries
# notice how it is left aligned, but once on the other side of the river,
#   we go back to right alignment vs left alignment
SELECT r.last_name,
       (SELECT MAX(YEAR(championship_date))
          FROM champions AS c
         WHERE c.last_name = r.last_name
           AND c.confirmed = 'Y') AS last_championship_year
  FROM riders AS r
 WHERE r.last_name IN
       (SELECT c.last_name
          FROM champions AS c
         WHERE YEAR(championship_date) > '2008'
           AND c.confirmed = 'Y');


----------------------------- PostgreSQL Data Types -----------------------------

Data Type	                  Type	     Value	                          Example Values
varchar(length)	            character	 up to length characters of text	canoe
text	                      character	 unlimited length of text	        a long string of text
integer	                    numeric	   whole numbers	                  42, -1423290
real	                      numeric	   floating-point numbers	          24.563, -14924.3515
decimal(precision, scale)	  numeric	   arbitrary precision numbers	    123.45, -567.89
timestamp	                  date/time	 date and time	                  1999-01-08 04:05:06
date	                      date/time	 only a date	                    1999-01-08
boolean	                    boolean	   true or false	                  true, false

# more on data types within PostgreSQL
# https://www.postgresql.org/docs/current/static/datatype.html


------------------------------------- NULL -------------------------------------

- represents nothing, aka the absence of any other value.
- when using NULL in a comparison operator, it will return NULL rather than true or false
- so use IS NULL or IS NOT NULL

---------------------------- Loading Database Dumps ----------------------------

- 2 ways to load SQL files into a PostgreSQL DB

$ psql -d my_database < file_to_import.sql
# This will execute the SQL statements within file_to_import.sql within the my_database database.

my_database=# \i ~/some/files/file_to_import.sql
# This will have the same effect as the first command, but does not require exiting a running psql session.
