# We returned back to our films table (inside sql_book server)

# table looks like this now

sql-course=# SELECT * FROM films;
           title           | year |   genre   |       director       | duration
---------------------------+------+-----------+----------------------+----------
 Die Hard                  | 1988 | action    | John McTiernan       |      132
 Casablanca                | 1942 | drama     | Michael Curtiz       |      102
 The Conversation          | 1974 | thriller  | Francis Ford Coppola |      113
 1984                      | 1956 | scifi     | Michael Anderson     |       90
 Tinker Tailor Soldier Spy | 2011 | espionage | Tomas Alfredson      |      127
 The Birdcage              | 1996 | comedy    | Mike Nichols         |      118
 Godzilla                  | 1998 | scifi     | Roland Emmerich      |      139
 Godzilla                  | 2014 | scifi     | Gareth Edwards       |      123

# What if we wanted to update only one Godzilla movie?
- We would have to get more specific.

UPDATE films SET duration = 141 WHERE title = 'Godzilla' AND year = 2014;

- this causes an issue as we would need to know two pieces of info about the row of data.

############################ SOLVING PROBLEM: KEYS ############################
solution: to this problem is to stop using values within the data to identify rows (unless they are unique to row)

Two types of keys to cover:

- Natural keys
- Surrogate key

############################### NATURAL KEY

- existing value in dataset that uniquely identifies row of data (ie: TIN)
- in reality, most of these identifiers arent truly unique
ie: phone number changes, not everyone has a TIN, phone numbers change.

- solution: use one existing value in combination -> composite key
- better solution: SURROGATE KEYS

############################### SURROGATE KEY

- value solely created for the purpose of identifying a row of data.
- common to call surrogate key = id (short for identifier)


-- This statement:
CREATE TABLE colors (id serial, name text);

-- is actually interpreted as if it were this one:
CREATE SEQUENCE colors_id_seq;
CREATE TABLE colors (
    id integer NOT NULL DEFAULT nextval('colors_id_seq'),
    name text
);

- sequence: special kind of relation that generates a series of numbers.
            sequence will remember the last number generated.

- how to check? first, '$ \d table_name' to determine the name associated with id
  typically: 'tablename_id_seq'

sql_book=# SELECT nextval('tablename_id_seq');

nextval
-------
      4

WATCH OUT! Once a number is returned by 'nextval' it is never used when adding more data
  to table (Even if we didnt use it.)

ie:
sql_book=# INSERT INTO colors (name) VALUES ('yellow');

INSERT 0 1
sql-course=# SELECT * FROM colors;
 id |  name
----+--------
  1 | red
  2 | green
  3 | blue
  5 | yellow


############################### ENFORCING UNIQUENESS

- to ensure unique id all the time, set the constraint:

sql_book=# ALTER TABLE colors ADD CONSTRAINT id_unique UNIQUE (id);

############################### PRIMARY KEYS

- specifying 'PRIMARY KEY', PostgreSQL enforces holding unique values in addition to
    preventing the column from holding NULL VALUES.

CREATE TABLE more_colors (id serial PRIMARY KEY, name text);

"equivalent"

CREATE TABLE more_colors (id serial NOT NULL UNIQUE, name text);

Following conventions in software development saves time, reduces confusion, and
  minimizes the amount of time needed to get up to speed on a new project.

Typical conventions for working with tables and primary keys:

1. All tables should have a primary key column called id.
2. The id column should automatically be set to a unique value as new rows are inserted into the table.
3. The id column will often be an integer, but there are other data types (such as UUIDs) that can provide specific benefits.

Do you have to declare a column as a PRIMARY KEY in every table? Technically, no. But doing so is generally a good idea.


# What is a UUID?

UUIDs (or universally unique identifiers): very large numbers that are used to identify individual
                                           objects or, when working with a DB, rows in a DB.

UUIDs are often represented using hexadecimal strings with dashes such as f47ac10b-58cc-4372-a567-0e02b2c3d479.

############################### PRACTICE PROBLEMS ###############################

# 1. Write a SQL statement that makes a new sequence called "counter".
CREATE SEQUENCE counter;

# 2. Write a SQL statement to retrieve the next value from the sequence created in #1.
SELECT nextval('counter');

# 3. Write a SQL statement that removes a sequence called "counter".
DROP SEQUENCE counter;

# 4. Is it possible to create a sequence that returns only even numbers?
Yes you can set a sequence to increment in even numbers by using optinal clause 'increment'

# 5. What will the name of the sequence created by the following SQL statement be?
#    CREATE TABLE regions (id serial PRIMARY KEY, name text, area integer);
'regions_id_seq'

# 6.
ALTER TABLE films ADD COLUMN id SERIAL PRIMARY KEY;

# 7. What error do you receive if you attempt to update a row to have a value for id that is used by another row?
INSERT INTO films (title, year, genre, director, duration, id) VALUES
('Hello Murphy', 1986, 'action', 'Olivia Volf', 433, 1);

ERROR: duplicate key value violates unique constraint "films_pkey"
DETAIL: Key(id)=(1) already exists.

# 8. What error do you receive if you attempt to add another primary key column to the films table?
ALTER TABLE films ADD COLUMN idz SERIAL PRIMARY KEY;

ERROR: multiple primary keys for table "films" are not allowed

# 9. Write a SQL statement that modifies the table films to remove its primary
#      key while preserving the id column and the values it contains.

- "sql_book=# \d films"
- get pkey name -> "films_pkey"
ALTER TABLE films DROP CONSTRAINT films_pkey;
