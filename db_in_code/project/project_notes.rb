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







.
