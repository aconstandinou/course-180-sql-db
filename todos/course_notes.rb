# We transitioned session data to database_persistence.rb file
# Added "pg" gem to our Gemfile -> bundle install

############################# DATABASE_PERSISTENCE #############################
- we moved our class into this file.
- connect to db using gem "pg"

...
require "pg"

  def initialize
    @db = PG.connect(dbname: "todos")
  end
...

########################### LOGGING DATABASE QUERIES ###########################
- we can track in our CLI each DB request made.
- ex:

"Version 1: print out to console each SQL statement"
...
  def all_lists
    sql = "SELECT * FROM lists;"
    puts "#{sql}" # this will output in CLI every time we access all_lists in our app and in the browser
    result = @db.exec(sql)

    result.map do |tuple|
      {id: tuple["id"], name: tuple["name"], todos: []}
    end
  end
...

- BUT! well end up doing this for every method...
- new method "query(sql_statement, *params)" # sql statement and any/all parameters
  to be used across our many methods in our DatabasePersistance class

"Version 2: Sinatra offers a logging"

# todo.rb
  before do
    @storage = DatabasePersistance.new(logger)
  end

# database_persistence.rb
  def initialize(logger)
    @db = PG.connect(dbname: "todos")
    @logger = logger
  end

  def query(sql_statement, *params)
    # splat operator always results in an array, hence why we dont need to
    #   surround the argument in [] before passing it into exec_params
    @logger.info("#{sql_statement}: #{params}")
    @db.exec_params(sql_statement, params)
  end

######################### LOADING RECORDS FROM DATABASE #########################

- as we were transitioning our session data over to our DB,
    and as we query from SQL, data returned are strings. We noticed that a bool
    value in a method was checking values of "t" and "f" and in Ruby, objects are truthy.

# todo.rb
# method having an issue

def todos_remaining_count(list)
  list[:todos].count { |todo| !todo[:completed] }
end

# database_persistence.rb
    def all_lists
      sql = "SELECT * FROM lists;"
      result = query(sql)

      result.map do |tuple|
        list_id = tuple["id"].to_i
        todo_sql = "SELECT * FROM todos WHERE list_id = $1"
        # this will return PG result object that contains data for every row in todos table with matching list_id
        todos_result = query(todo_sql, list_id)

        todos = todos_result.map do |todo_tuple|
          { id: todo_tuple["id"].to_i,
            name: tuple["name"],
            completed: todo_tuple["completed"] == "t" } # this solves our issue in string "t" from DB vs. boolean in Ruby.
        end

        {id: list_id, name: tuple["name"], todos: todos}
      end
    end


######################### SOLVING THE RELOADING PROBLEM #########################

- any code outside of todo.rb when changed, needs to kill and restart the server.
- why? require "sinatra/reloader"

defining a route, or helper or any functionality in Sinatra it requires a reload

- our database_persistence.rb file doesnt have that reloader.

Solution -> within todo.rb and configure block:

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
  also_reload "database_persistence.rb" # included extension of the file .rb, different than Ruby require system
end

########################### DEVELOPMENT CONFIGURATION ###########################

- if you recall, Sinatra knows what environment were in via the rack.env variable
- Sinatra provides "development?" method and returns a bool value.

in our todo.rb app, we can set another configure block to handle all things we want in development

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

this helps fix code reload after its been sent into production and any related issues.

########################## DEPLOYING PG APPS TO HEROKU ##########################

1. Make sure code works and you can commit to git repo locally.












.
