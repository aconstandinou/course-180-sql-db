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
