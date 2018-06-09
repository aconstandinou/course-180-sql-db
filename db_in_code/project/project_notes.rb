###############################################################################
############################### DATABASE DESIGN ###############################

Requirements
- Create a database to store the expenses managed by this project.

Implementation
- Design a table called expenses that can hold the data for expenses.
- This table should have columns named id, amount, memo, and created_on.
- Write the SQL to create that table into a file called schema.sql.
- Create a database and use schema.sql to setup the database for the application.

################################### SOLUTION ###################################

# createdb expenses
# created file -> schema.sql
# added to our schem.sql file following code
CREATE TABLE expenses (
  id serial PRIMARY KEY,
  amount numeric(6,2) NOT NULL,
  memo text NOT NULL,
  created_on date NOT NULL
);

# load our table -> psql -d expenses < schema.sql

# Practice Problems
# 1 - What is the largest value allowed in 'amount' column? Use psql to demonstrate this.
Max number is 9999.99

# will fail
INSERT INTO expenses (amount, memo, created_on) VALUES
  (10000.00, 'test', '2018-06-07');

INSERT INTO expenses (amount, memo, created_on) VALUES
  (9999.99, 'test', '2018-06-07');

# 2 - What is the smallest value allowed in 'amount' column? Use psql to demonstrate this.
Min number is -9999.99

# will fail
INSERT INTO expenses (amount, memo, created_on) VALUES
  (-10000.00, 'test', '2018-06-07');
INSERT INTO expenses (amount, memo, created_on) VALUES
  (-9999.99, 'test', '2018-06-07');

# 3 - Add check constraint to expenses table to ensure that amount only holds positive value.
ALTER TABLE expenses ADD CHECK (amount >= 0.00);


################################################################################
############################### LISTING EXPENSES ###############################

# add new data to our table

INSERT INTO expenses (amount, memo, created_on) VALUES (14.56, 'Pencils', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (3.29, 'Coffee', NOW());
INSERT INTO expenses (amount, memo, created_on) VALUES (49.99, 'Text Editor', NOW());

Requirements
Connect to the expenses database and print out the information for all expenses in the system.

db = PG.connect(dbname: "expenses")
result = db.exec "SELECT * FROM expenses;"

result.each do |tuple|
  columns = [ tuple["id"].rjust(3),
              tuple["created_on"].rjust(10),
              tuple["amount"].rjust(12),
              tuple["memo"] ]

  puts columns.join(" | ")
end

################################################################################
############################### DISPLAYING HELP ###############################

Describe what is happening on line 20 of the Solution shown above.
<<~HELP
HELP

known as HEREDOC block (multiline string), squiggly line allows us to indent to least indented line.
new feature of Ruby 2.3 that strips leading whitespace from the beginning of each
  line of the string so that it can be indented in a way that is natural for the code

################################################################################
############################### ADDING EXPENSES ################################

1. Add a command, add, that can be used to add new expenses to the system. It should look like this in use:

2. Make sure that this command is always passed any additional parameters needed to add an expense.
     If it isnt display an error message:

# changed our code so that CONNECTION is now a global variable accessible within all methods
# added a new method to handle adding in new data

CONNECTION = PG.connect(dbname: "expenses")

def add_expense(amount, memo)
 date = Date.today

 sql = "INSERT INTO expenses (amount, memo, created_on) VALUES
        (#{amount}, '#{memo}', '#{date}')"

 CONNECTION.exec(sql)
end

# Problem - Can you see any potential issues with the Solution code above?
Yes. At the moment, there is no check other than within our SQL table to see
  whether or not the data the user inputs is valid data, ie: a number greater than 0, and a string memo.

################################################################################
######################### HANDLING PARAMETERS SAFELY ###########################

"pg" gem has a piece of functionality incorporated to help mitigate SQL injection attacks.

instead of "PG::Connection#exec", well use "PG::Connection#exec_params"
# documentation: https://deveiate.org/code/pg/PG/Connection.html#method-i-exec_params

seems like PostgreSQL binds parameters as $1, $2, $3 inside SQL query.
0th element of the params array is bound to $1

example using our current DB

As a review, here is how to execute a simple SQL statement using PG::Connection#exec
>> connection.exec("SELECT 1 + 1").values
=> [["2"]]

Now, lets use PG::Connection#exec_param
>> connection.exec_params("SELECT 1 + $1", [1]).values
=> [["2"]]

# Note that we arent adding quotes around the placeholder within the statement
>> connection.exec_params("SELECT upper($1)", ["test"]).values
=> [["TEST"]]

# There can be as many placeholders as needed in the statement, as long as the
#   same number of values are passed in the second argument Array to #exec_params:
>> connection.exec_params("SELECT position($1 in $2)", ["t", "test"]).values
=> [["1"]]

# Practice Problems

# 1. What happens if you use two placeholders in the first argument to PG::Connection#exec_params,
#    but only one in the Array of values used to fill in those placeholders?
our test:
connection.exec_params("SELECT position($1 in $2)", ["t"]).values

our result:
PG::ProtocolViolation: ERROR: bind message supplies 1 parameters but prepared statemtnt "" requires 2

# 2. Update the code within the add_expense method to use exec_params instead of exec.

def add_expense(amount, memo)
  date = Date.today

  sql = "INSERT INTO expenses (amount, memo, created_on) VALUES ($1, $2, $3)"
  CONNECTION.exec_params(sql, [amount, memo, date])
end

# 3. What happens when the same malicious arguments are passed to the program now?

in the malicious example:
$ ./expense add 0.01 "', '2015-01-01'); DROP TABLE expenses; --"

Answer: it still is added to our list, and just looks odd.

running this below, we can its added to our list
$ expense.rb list

4  | 2018-06-07 |           14.56 | Pencils
...
10 | 2018-06-09 |            0.01 | ', '2015-01-01'); DROP TABLE expenses; --



.
