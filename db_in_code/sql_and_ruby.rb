####################### EXECUTING SQL STATEMENTS IN RUBY #######################

Step 1) Import SQL file into a DB
         file saved -> sql_and_ruby.sql
         in CLI
         createdb sql_and_ruby
         CD into .sql file location
         psql -d sql_and_ruby < sql_and_ruby.sql

Step 2) Video
- within Ruby CLI, ran command pry
- this allows us to build an app and connect to DB via the command-line

# Video Code

db = PG.connect(dbname: "sql_and_ruby") # then hit enter
# this created a connection object to interact with DB in ruby
# note: feature of pry to see what a method is doing -> show-method PG.connect
#       this actually showed us what method does
'''
def self::connect( *args )
  return PG::Connection.new ( *args )
'''

# with 'db' object, we can send in SQL queries to have it return the result.
result = db.exec "SELECT 1"

# this returns a result object
# can now 'cd' into the result, which changes the context that our interactive Ruby is operating at into the scope of that object

cd result

[9] pry(#<PG::Result>):1>

# to list out available methods
ls

# terminology of the gem methods can be a bit confusing.
tuple = Ruby hash

# to go back to top level
cd ..

result = db.exec "SELECT * FROM films;"

# look at values, returns an array of arrays
result.values

# how to interact with result objects

result.field # column names
results.values # values of each row as an array of arrays
result.values.size # size method will return size of array
--or--
result.ntuples # size of returned array

# each method -> loop thru the results
#      calling each method on pg result method, and pass it a block, that block
#      is going to yield a hash, where the keys are the name of the columns,
#      and values are the data in each row
result.each do |tuple|
  puts "#{tuple["title"]} came out in #{tuple["year"]}"
end

# each_row method -> yields an array, rather than a hash.
result.each_row do |array|
  puts "#{array[0]} came out in #{array[1]}"
end

# note, that result[0] returns a hash where every value is a string.

# field_values method -> name of column to return values for
result.field_values("duration")

# column_values -> provide the index rather than the name
result.column_values(2)

########################## REVIEW OF USEFUL COMMANDS ##########################

# COMMAND                                        WHAT IT DOES

# PG.connect(dbname: "a_database")	             Create a new PG::Connection object
# connection.exec("SELECT * FROM table_name")	   execute a SQL query and return a PG::Result object
# result.values	                                 Returns an Array of Arrays containing values for each row in result
# result.fields	                                 Returns the names of columns as an Array of Strings
# result.ntuples	                               Returns the number of rows in result
# result.each(&block)	                           Yields a Hash of column names and values to the block for each row in result
# result.each_row(&block)	                       Yields an Array of values to the block for each row in result
# result[index]	                                 Returns a Hash of values for row at index in result
# result.field_values(column)	                   Returns an Array of values for column, one for each row in result
# result.column_values(index)	                   Returns an Array of values for column at index, one for each row in result
