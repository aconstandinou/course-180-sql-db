# NULL values
Example given of a DB holding employee data.
Cols = first_name, last_name, department, vacation_remaining

Schema allows for NULL values when INSERTing new employees into the DB.

Extracting data, NULL appears at the top of an 'ORDER BY vacation_remaining DESC;'

NULL Values sort at the top. Remember, any operator on a NULL value returns NULL.
This makes it impossible to compare NULL value with any other value which is normally
  how a set of values would be sorted.

Because of this arbitrary ordering, NULL values will display first or last. In PostgreSQL, they appear first.

"Current look at this issue"
sql-course=# SELECT * FROM employees ORDER BY vacation_remaining DESC;
 first_name | last_name | department | vacation_remaining
------------+-----------+------------+--------------------
 Haiden     | Smith     |            |
 Leonardo   | Ferreira  | finance    |                 14
 Sara       | Mikaelsen | operations |                 14
 Lian       | Ma        | marketing  |                 13

"What if we wanted to pay out unused vacation?"
SELECT *, vacation_remaining * 15.50 * 8 AS amount FROM employees ORDER BY vacation_remaining DESC;

first_name  | last_name | department | vacation_remaining | amount
------------+-----------+------------+--------------------+---------
Haiden      | Smith     |            |                    |
Leonardo    | Ferreira  | finance    |                 14 | 1736.00
Sara        | Mikaelsen | operations |                 14 | 1736.00
Lian        | Ma        | marketing  |                 13 | 1612.00

- Now we could set the column constraint to NOT NULL (After deleting rows with NULL
    or else it wont allow us to add the constraint)
- Better idea, set a default value.

ALTER TABLE employees ALTER COLUMN vacation_remaining SET DEFAULT 0;

NOT NULL is one of several constraints available that help make a database schema as precise and protective as possible.

############################### PRACTICE PROBLEMS ##############################
# 1.
The resulting value will also be NULL, which signifies an unknown value.

# 2.
ALTER TABLE employees ALTER COLUMN department SET DEFAULT 'unassigned';

UPDATE employees SET department = 'unassigned' WHERE department IS NULL;

ALTER TABLE employees ALTER COLUMN department SET NOT NULL;

# 3.

CREATE TABLE temperatures (
  date date NOT NULL,
  low integer NOT NULL,
  high integer NOT NULL
);

# 4.
INSERT INTO temperatures VALUES
('2016-03-01', 34, 43),
('2016-03-02', 32, 44),
('2016-03-03', 31, 47),
('2016-03-04', 33, 42),
('2016-03-05', 39, 46)
('2016-03-06', 32, 43),
('2016-03-07', 29, 32),
('2016-03-08', 23, 31),
('2016-03-09', 17, 28);


# 5.
SELECT date, (high + low)/2 AS average
  FROM temperatures
 WHERE date BETWEEN '2016-03-02' AND '2016-03-08';

# BETWEEN above is equivalent to:
# date >= '2016-03-02' AND date <='2016-03-08'

# 6.

ALTER TABLE temperatures ADD COLUMN rainfall integer DEFAULT 0;

# 7.

UPDATE employees
   SET rainfall = (high + low)/2 - 35
 WHERE (high + low)/2 > 35;

# 8.
# First, update column to decimals rather than integers.
ALTER TABLE temperatures ALTER COLUMN rainfall TYPE DECIMAL(6, 3);

# Second, convert all values from mm to inches.
# ie: 1 mm = 0.03937 inches

UPDATE employees
   SET rainfall = rainfall * 0.39;

# 9.

ALTER TABLE temperatures RENAME TO weather;

# 10.

psql meta-command = \d weather

# 11.

$ pg_dump -d -sql-course -t weather --inserts > dump.sql
"Breakdown -> pg_dump -d db_name -t table_name > dumpfilename.sql"
# just make sure you do this from CLI where you want to dump the file

# Resulting dump.sql file

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: weather; Type: TABLE; Schema: public; Owner: instructor; Tablespace:
--

CREATE TABLE weather (
    date date NOT NULL,
    low integer NOT NULL,
    high integer NOT NULL,
    rainfall numeric(6,3) DEFAULT 0
);


ALTER TABLE weather OWNER TO instructor;

--
-- Data for Name: weather; Type: TABLE DATA; Schema: public; Owner: instructor
--

INSERT INTO weather VALUES ('2016-03-07', 29, 32, 0.000);
INSERT INTO weather VALUES ('2016-03-08', 23, 31, 0.000);
INSERT INTO weather VALUES ('2016-03-09', 17, 28, 0.000);
INSERT INTO weather VALUES ('2016-03-01', 34, 43, 0.117);
INSERT INTO weather VALUES ('2016-03-02', 32, 44, 0.117);
INSERT INTO weather VALUES ('2016-03-03', 31, 47, 0.156);
INSERT INTO weather VALUES ('2016-03-04', 33, 42, 0.078);
INSERT INTO weather VALUES ('2016-03-05', 39, 46, 0.273);
INSERT INTO weather VALUES ('2016-03-06', 32, 43, 0.078);


--
-- PostgreSQL database dump complete
--
