# 1.
# First, created new db
createdb more_constraints
# Second, loaded file from LS course.
psql -d more_constraints < more_constraints.sql


# 2.
ALTER TABLE films ALTER COLUMN title SET NOT NULL;
ALTER TABLE films ALTER COLUMN year SET NOT NULL;
ALTER TABLE films ALTER COLUMN genre SET NOT NULL;
ALTER TABLE films ALTER COLUMN director SET NOT NULL;
ALTER TABLE films ALTER COLUMN duration SET NOT NULL;

# 3.
It adds not null to Modifiers column

# 4.
ALTER TABLE films ADD UNIQUE (title);

"LS creates a name for the constraint"
ALTER TABLE films ADD CONSTRAINT title_unique UNIQUE (title);

# 5.
It appears as an index
Indexes:
    "title_unique" UNIQUE CONSTRAINT, btree (title)

# 6.
ALTER TABLE films DROP CONSTRAINT films_title_key;
"make sure that the 'films_title_key' matches the name of the unique constraint
found under d\ table and Indexes"

# 7.
ALTER TABLE films ADD CONSTRAINT title_check CHECK (char_length(title) > 0);

# 8.
INSERT INTO films VALUES ('', 2015, 'action', 'Olivia', 123);
error shown is as follows
ERROR: new row for relation "films" violates check constraint "title_check"
DETAIL: Failing row contains (, 2015, action, Olivia, 123).

# 9.
It is added as a 'Check constraint'

# 10.
ALTER TABLE films DROP CONSTRAINT title_check;

# 11.
ALTER TABLE films ADD CONSTRAINT year_limit CHECK (year >= 1900 AND year <= 2100);

# 12.
Constraint appears as a 'check constraint'

# 13.
ALTER TABLE films
ADD CONSTRAINT director_name
CHECK (length(director) >= 3 AND position(' ' in director) > 0);

# 14.
Constraint appears as a 'check constraint' as 'director_name'

# 15

UPDATE films
   SET director = 'Johnny'
 WHERE title = 'Die Hard';

raises an error ->
ERROR: new row for relation "films" violates check constraint "director_name"
DETAIL: Failing row contains (...)

# 16.
# List three ways to use the schema to restrict what values can be stored in a column.

1. Data type (which can include a length limitation)
2. NOT NULL Constraint
3. Check Constraint

# 17. Is it possible to define a default value for a column that will be
#       considered invalid by a constraint? Create a table that tests this.

# We will try this by changing one of the columns in films that has a NOT NULL constraint
#   and set its default to ''

ALTER TABLE films ALTER COLUMN title SET DEFAULT '';
# this actually worked.

# lets try to add in a row:
INSERT INTO films
VALUES (DEFAULT, 2015, 'action', 'Olivia', 123);

# results in error

# 18.

Using \d $tablename, where $tablename is the name of the table.
