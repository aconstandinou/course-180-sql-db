################################# OPTIMIZATION #################################

- in general: app that makes fewer queries will be faster than one that makes more.

- course goal: 'N+1' queries, indexes, how to implement them and trade-offs,
                  comparing different SQL statements.
                  subquery, how to use it

########################## IDENTIFYING OPTIMIZATIONS ##########################

- still using our Todos application:

  - having a list of Todos, we can see that each one notifies us of how many completed/how many total todos
  - reloading the page, we can see the logger output
  - with 7 lists of todos, and the original query, weve queried the DB 8 times already
    I, [########################] INFO -- : SELECT * FROM list: []
    I, [########################] INFO -- : SELECT * FROM todos WHERE list_id = $1: [2]
    ...
    I, [########################] INFO -- : SELECT * FROM todos WHERE list_id = $1: [8]
  - think about it, if you had 100 todo lists, just to load the page we would end up
      querying 'N+1' = 100+1 = 101 just to load the page
  - method in question 'all_lists' #database_persistance,rb

# option 1: change this to be single query with JOIN clause
# option 2: changes to other parts of the app.
#           first, change the initial query to fetch all lists and count todos

# original
  def all_lists
    sql = "SELECT * FROM lists;"
    result = query(sql)

    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_list(list_id)
      {id: list_id, name: tuple["name"], todos: todos}
    end
  end

# erb file in question
# lists.erb
# <ul id="lists">
#   <% sort_lists(@lists) do |list| %>
#     <li class="<%= list_class(list) %>">
#       <a href="/lists/<%= list[:id] %>">
#         <h2><%= list[:name] %></h2>
#         <p>
#           <%= todos_remaining_count(list) %> / <%= todos_count(list) %>
#         </p>
#       </a>
#     </li>
#   <% end %>
# </ul>
#
# <% content_for :header_links do %>
#   <a class="add" href="/lists/new">New List</a>
# <% end %>

# methods in question
todos_remaining_count(list)
todos_count(list)

# simply counts the size of list[:todos] array
def todos_count(list)
  list[:todos].size
end

# simply checks number of todos not completed
def todos_remaining_count(list)
  list[:todos].count { |todo| !todo[:completed] }
end

# now, if we want to look at where a certain method is being used, in console:
$ git grep -n todos_count

# C:\Users........................
todo.rb:20:    todos_count(list) .....
todo.rb:27:  def todos_count(list)
views/lists.erb:7:       <%= todos....

# this is super helpful in isolating all areas once we change a method or the app

# logging into PostgreSQL via CLI, we started working on creating a SQL query
#   that could also help with getting our lists and # of todos associated.
#   We used a JOIN to help out.

NOTE: after solving for a complex SQL query, metacommand "\e" will output the last
  SQL command to notepad.

# so far SQL query to get us number of todos associated per list

SELECT lists.*, COUNT(todos.list_id) AS todos_count
 FROM lists
 JOIN todos ON todos.list_id = lists.id
GROUP BY lists.id;

# still missing our number of completed todos/total todos per list and to accomplish this
#  were going to turn all true values in todos[completed] to null values.

SELECT COUNT(NULLIF(todos.completed, true)) FROM todos;

# merging our existing SELECT queries

SELECT lists.*,
       COUNT(todos.list_id) AS todos_count,
       COUNT(NULLIF(todos.completed, true)) AS todos_remaining
       FROM lists
LEFT JOIN todos ON todos.list_id = lists.id
GROUP BY lists.id;

# we also need to add an ORDER BY clause since the SQL query is returning data
#   in the order it was created.

SELECT lists.*,
       COUNT(todos.list_id) AS todos_count,
       COUNT(NULLIF(todos.completed, true)) AS todos_remaining
       FROM lists
LEFT JOIN todos ON todos.list_id = lists.id
GROUP BY lists.id
ORDER BY lists.name;

# TWO EFFICIENCIES (OPTIMIZATION) FOR OUR COMPLEX SQL QUERY:
# 1 - less data needs to be sent over the network which would be more obvious in much
#     larger data sets.
# 2 - all data is coming back into Ruby to be processed.

# After these changes, we now need to update the actual page that lists our todos
- essentially, accessing list has different keys.
- method causing error after our changes:

# todo.rb
def list_complete?(list)
  # todos_count(list) > 0 && todos_remaining_count(list) == 0
  list[:todos_count] > 0 && list[:todos_remaining_count] == 0
end

# database_persistance.rb returns list with following keys:
def find_list(id)
  sql = "SELECT * FROM lists WHERE id = $1"
  result = query(sql, id)
  # we need to convert 'result' into hash that our app requires to load data
  #   hash with symbol keys
  tuple = result.first
  list_id = tuple["id"].to_i
  todos = find_todos_list(list_id)
  {id: list_id, name: tuple["name"], todos: todos}
end

# APPROACH BY LS to bring both methods closer together.
- modify each method, its okay to duplicate code
- once everything works with duplication, you can create methods for duplicated code
  and run any tests.

################################################################################
#################################### INDEXES ####################################

- index: mechanism that SQL engines use to speed up queries.
         storing indexed data in a table-like structure.
         results of search provide a link back to the record(s) to which indexed data belongs.

example: index of a book

A
...
E
ease (keyword), 296
Eden, Dan, 300
elastic transitions, 294-305
  elastic trans 1, 295
  elastic trans 2, 340

SQL Example

# books table
# title column                     | author column
# Book 1                           | William Black
# Book 2                           | Oliva Wolf
# Book 3                           | Charles Blackstein
# Book 4                           | William Black

# books_author_idx
# William Black
# Oliva Wolf
# Charles Blackstein

- to index author column in books table, we just need to search the index for the name
    that matched the search condition to identify relevant rows.
In a real database, our author column would probably be a Foreign Key id instead, but the principle remains the same.

################## WHEN TO USE AN INDEX? ##################
Indexes: special lookup tables that the database search engine can use
         to speed up data retrieval. Simply put, an index is a pointer to data in a table.

- reasons why indexing can be slow?
1) when you build an index of a field, reads become faster,
     but every time a row is updated or inserted, the index must be updated as well.
     Not just updating table but also the index.

An index helps to speed up SELECT queries and WHERE clauses; however, it slows
  down data input, with UPDATE and INSERT statements.
  Indexes can be created or dropped with no effect on the data.

Some rules of thumb for the trade-off of indexes.

- Indexes are best used in cases where sequential reading is inadequate.
    For ex: columns that aid in mapping relationships (such as Foreign Key columns),
            or columns that are frequently used as part of an ORDER BY clause,
            are good candidates for indexing.
- They are best used in tables and/ or columns where the data will be read much
    more frequently than it is created or updated.

# TYPES OF INDEX

- within POSTGRESQL: B-tree, Hash, GiST, GIN.
# additional info: https://www.postgresql.org/docs/9.2/static/indexes-types.html

# CREATING AN INDEX

When you define a PRIMARY KEY constraint, or a UNIQUE constraint, on a column
  you automatically create an index on that column

Example:

CREATE TABLE authors (
  id serial PRIMARY KEY,
  name varchar(100) NOT NULL
);

CREATE TABLE books (
  id serial PRIMARY KEY,
  title varchar(100) NOT NULL,
  isbn char(13) UNIQUE NOT NULL,
  author_id int REFERENCES authors(id)
);

# lets look at the schema

my_books=# \d books

Table "public.books"
Column     |          Type          |                     Modifiers
----------------+------------------------+----------------------------------------------------
id             | integer                | not null default nextval('books_id_seq'::regclass)
title          | character varying(100) | not null
isbn           | character(13)          | not null
author_id      | integer                |
Indexes:
"books_pkey" PRIMARY KEY, btree (id)
"books_isbn_key" UNIQUE CONSTRAINT, btree (isbn)
Foreign-key constraints:
"books_author_id_fkey" FOREIGN KEY (author_id) REFERENCES authors(id)

- notice two indexes under "Indexes" within the table schema

The btree part of each entry identifies the type of index used
  (PostgreSQL uses B-tree by default for all indexes, and it is the only
  type available for unique indexes),
  followed by the name of the column that is indexed.

- Unlike PRIMARY KEY and UNIQUE constraints, FOREIGN KEY constraints do not automatically create an index on a column.
  You would need to explicitly create the index on the column.
  If index_name is omitted, PostgreSQL automatically generates a unique name for the index.

The general form for adding an index to a table is:

"CREATE INDEX index_name ON table_name (field_name);"

To add an index to the author_id column of the books table, we could execute the following statement:
"CREATE INDEX ON books (author_id);"

# Unique and Non-unique
- PRIMARY KEY and UNIQUE constraints = unique index
- Unique index = multiple table rows with equal values for that index are not allowed
                 "books_pkey" and "books_isbn_key"

- Non-unique index = "books_author_id_idx" index that we added doesnt enforce uniqueness,
                     meaning that the same value can occur multiple times in the indexed column.

# Multicolumn Indexes
"CREATE INDEX index_name ON table_name (field_name_1, field_name_2);"

# Partial Indexes
- limited to only a portion of a columns data values, ie: authors that start with 'A'

# Deleting Indexes

"DROP INDEX" command can be used to delete the index that was created.
In order to execute the command you need to refer to the index by its name.

psql command "\di"

List of relations
Schema |        Name         | Type  | Owner |  Table
--------+---------------------+-------+-------+---------
public | authors_pkey        | index | User  | authors
public | books_author_id_idx | index | User  | books
public | books_isbn_key      | index | User  | books
public | books_pkey          | index | User  | books

Above we can see that there are three indexes on the books table, and one on the authors table.

Lets delete the books_author_id_idx we created earlier:

"DROP INDEX books_author_id_idx;"

my_books=# \di
                 List of relations
 Schema |      Name      | Type  | Owner |  Table
--------+----------------+-------+-------+---------
 public | authors_pkey   | index | karl  | authors
 public | books_isbn_key | index | karl  | books
 public | books_pkey     | index | karl  | books

########################### COMPARING SQL STATEMENTS ###########################

- recall, SQL being a predominantly declarative language
- it describes 'what' needs to be done but not the detail of 'how' to do it

###################### Assessing a Query with EXPLAIN

PostgreSQL provides a useful command called EXPLAIN which gives a step by
  step analysis of how the query will be run internally

'EXPLAIN' allows you to access and read that 'query plan'.

'query plan': PostgreSQL devises an appropriate query plan for each query it receives.

'EXPLAIN': prepend to SQL query, does not execute the query but returns the plan for that query.

my_books=# EXPLAIN SELECT * FROM books;
QUERY PLAN
----------------------------------------------------------
Seq Scan on books  (cost=0.00..12.60 rows=260 width=282)
(1 row)

The structure of the query plan is a node-tree.
The more 'elements' that there are to your query, the more nodes there will be in the tree.
The example above explains a very simple query, so there is only one node in the plan tree.
Each node consists of the node type (in this case a sequential scan on the books table) along
  with estimated cost for that node (start-up cost, followed by total cost),
  the estimated number of rows to be output by the node,
  and the estimated average width of the rows in bytes.

- to compare queries is the estimated 'total cost' value of the top-most node

###################### EXPLAIN ANALYZE

- 'EXPLAIN' is only an estimate of the cost of the query.
- 'EXPLAIN ANALYZE' uses actual data to return the information.

# EXTRA RESOURCES
# https://dev.to/eviedently/a-rubyists-guide-to-postgresqls-explain
# https://www.postgresql.org/docs/current/static/using-explain.html

########################### SUBQUERIES ###########################
# https://launchschool.com/books/sql/read/joins#subqueries
- Example of subquery: executing a SELECT query, and then using the results of that SELECT
                         query as a condition in another SELECT query.
                         This is called nesting, and the query that is nested is referred to as a subquery.

PostgreSQL expressions that can be used specifically with sub-queries: 'IN', 'NOT IN', 'ANY', 'SOME', 'ALL'

Example:
SELECT title FROM books WHERE author_id =
  (SELECT id FROM authors WHERE name = 'William Gibson');

# IN
'IN' compares an evaluated expression to every row in the subquery result.
  If an equal row is found, then the result of IN is 'true', otherwise it is 'false'.

SELECT name FROM authors WHERE id IN
  (SELECT author_id FROM books
    WHERE title LIKE 'The%');

Steps
1 - nested query returns a list of author_id values (2, 3) from books table where title of book for that row starts with 'The'.
2 - outer query returns name value from any row of the authors table where the id for that row is in the results from the nested query.

# NOT IN
'NOT IN' is similar to IN except that the result of NOT IN is 'true' if an equal row is not found, and 'false' otherwise.

SELECT name FROM authors WHERE id NOT IN
  (SELECT author_id FROM books
    WHERE title LIKE 'The%');

# ANY/ SOME

- 'ANY' and 'SOME' are synonyms, and can be used interchangeably.
- expressions are used along with an operator ie: '=', '<', '>'

SELECT name FROM authors WHERE length(name) > ANY
  (SELECT length(title) FROM books
    WHERE title LIKE 'The%');

# ALL

- used along with an operator ie: '=', '<', '>'
- result 'ALL' is true only if all the results are true when the expression to
    the left of the operator is evaluated against operator against the results of the nested query.

SELECT name FROM authors WHERE length(name) > ALL
  (SELECT length(title) FROM books
    WHERE title LIKE 'The%');

Note: when the <> / != operator is used with 'ALL', this is equivalent to 'NOT IN'

# documentation
# https://www.postgresql.org/docs/9.6/static/functions-subquery.html

############################ WHEN TO USE SUBQUERIES

example: if you want to return data from one table conditional on data from another table,
           but dont need to return any data from the second table,
           then a subquery may make more logical sense and be more readable.
