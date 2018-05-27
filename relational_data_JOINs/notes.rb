################################################################################
########################### WHAT IS RELATIONAL DATA? ###########################

- A 'relation' is usually another way to say "table".
- A 'relationship' is an association between the data stored in those relations.

For a developer, relational data can be translated into a more functional
  definition: working with more than one table at a time.

#################################################################################
###################### Database Diagrams: Levels of Schema ######################

level of abstraction (schema): conceptual
                                   |
                                logical
                                   |
                                physical


- conceptual: bigger objects and higher level, ie: high level method and data
- logical: contain a list of all attributes + data types, but not specific.
           'rough draft' and move it into a physical schema.
- physical: DB specific implementation of the 'conceptual' model.
            ie: attributes an entity can hold, data types, rules of entities/attributes

# Actual Definitions
conceptual schema: high level design focused on identifying entities and their relationships.
                   recall, "ERD" entity-relationship diagrams.
                   "ERD" = conceptual schema
                   connection between entities: -------------  and   -------------€
                                                    (one)               (many)
                   example used, CONTACT -----€ CALLS
                                 (one contact to many calls)
logical schema:
physical schema: low level DB specific design focused on implementation
                 example, CONTACT and CALLS
                 -------------------------     ---------------------------
                 contacts                      calls
                 -------------------------     ---------------------------
                 id SERIAL            (P)|__   | id SERIAL                        (P)
                 first_name TEXT      (N)|  |  | when TIMESTAMP WITHOUT TIME ZONE (N)
                 last_name TEXT       (N)|  |  | duration INTEGER                 (N)
                 number VARCHAR(10)   (N)|  |->| contact_id INTEGER            (F)(N)

(P) - primary key
(N) - NOT NULL
(F) - foreign key (points back to primary key in another table)

#################################################################################
################## Database Diagrams: Cardinality and Modality ##################


'cardinality': number of objects on each side of the relationship (1:1, 1:M, M:M)

'modality': distinguishes whether relation is 'required' (1) or 'optional' (0)

example: AUTHOR (one-to-many) BOOK (many-to-many) CATEGORY
        - each author has a book, and each book has an author.
        - each book doesnt need a category, and each category doesnt need to have a book.

crows foot notation: refers to the I and O weve been incorporating into our relationships
ie: --I-O----- : 1 and 0, modality = 0
    --I-I----- : 1 and 1, modality = 1
    ---O-----€ : 0      , modality = 0
    ---I-----€ : 1      , modality = 1

if modality = 1, minimum occurence must be 1.

#################################################################################
################################ Review of JOINs ################################

video example: COMMENTS table and USERS table.
               COMMENTS table had data pertaining to only some users.
               USERS table had various users, but not each one had a COMMENT.

# INNER JOIN
SELECT * FROM comments INNER JOIN users ON comments.user_id = users.id;

- tells DB that it needs to match data in both tables to return row of matching data.

to get all values from a table, we can use LEFT JOIN, RIGHT JOIN,

# LEFT JOIN
SELECT * FROM comments LEFT OUTER JOIN users ON comments.user_id = users.id;

- tells DB, take every row in LEFT table and matching RIGHT table data.
- output will always have every row in LEFT table, and any missing matches from
    RIGHT table will have NULL values.

# RIGHT JOIN
SELECT * FROM comments RIGHT OUTER JOIN users ON comments.user_id = users.id;

- identical to LEFT, but rather switch every point to RIGHT table

# FULL JOIN
- combo of LEFT OUTER and RIGHT OUTER join

# CROSS JOIN
- contains any possible combo from tables.
- has no 'ON' clause.
- would every row in one table, with every row in another.

# MULTIPLE JOINS

- joining more than 2 tables together.


################################################################################
######################### Working with Multiple Tables #########################

# 1.
- Saved .sql file in "...:\...\...\launch_school\course_180\relational_data_JOINs\multi_tables.sql"
- Created new db, $ createdb sql_course
- in ruby cli, cd into folder
- in ruby cli, $psql -d sql_course < multi_tables.sql

# 2.

SELECT COUNT(id) FROM tickets;

# 3.

SELECT COUNT(DISTINCT customer_id) FROM tickets;

# 4.

SELECT COUNT(DISTINCT tickets.customer_id) / COUNT(DISTINCT customers.id)::float * 100 AS percent
  FROM customers
LEFT OUTER JOIN tickets ON tickets.customer_id = customers.id;

# 5.

SELECT e.name, COUNT(t.id) AS popularity
  FROM events AS e
  LEFT OUTER JOIN tickets AS t
  ON t.event_id = e.id
  GROUP BY e.id
  ORDER BY popularity DESC;

# why does this work?

tables: events AS e and tickets AS t
rename aggregage COUNT(t.id) AS popularity
to get name, we LEFT OUTER JOIN tickets as T on ON t.event_id = e.id
GROUP BY e.id

# 6.

SELECT customers.id, customers.email, COUNT(DISTINCT tickets.event_id)
  FROM customers INNER JOIN tickets on tickets.customer_id = customers.id
  GROUP BY customers.id
  HAVING COUNT(DISTINCT tickets.event_id) = 3;


# 7.

SELECT events.name AS event, events.starts_at, sections.name AS section, seats.row, seats.number AS seat
  FROM tickets
    INNER JOIN events ON tickets.event_id = events.id
    INNER JOIN customers ON tickets.customer_id = customers.id
    INNER JOIN seats ON tickets.seat_id = seats.id
    INNER JOIN sections ON seats.section_id = sections.id
WHERE customers.email = 'gennaro.rath@mcdermott.co';
