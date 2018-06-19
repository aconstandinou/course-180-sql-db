require "pg"

class DatabasePersistance

  def initialize(logger)
    @db = if Sinatra::Base.production?
        PG.connect(ENV['DATABASE_URL'])
      else
        PG.connect(dbname: "todos")
      end
    @logger = logger
  end

  def query(sql_statement, *params)
    # splat operator always results in an array, hence why we dont need to
    #   surround the argument in [] before passing it into exec_params
    @logger.info("#{sql_statement}: #{params}")
    @db.exec_params(sql_statement, params)
  end

  def disconnect
    @db.close
  end

  def find_list(id)
    sql = <<~SQL
    SELECT lists.*,
           COUNT(todos.list_id) AS todos_count,
           COUNT(NULLIF(todos.completed, true)) AS todos_remaining_count
         FROM lists
         LEFT JOIN todos ON todos.list_id = lists.id
         WHERE lists.id = $1
         GROUP BY lists.id
         ORDER BY lists.name;
    SQL
    result = query(sql, id)
    # we need to convert 'result' into hash that our app requires to load data
    #   hash with symbol keys
    tuple_to_list_hash(result.first)
  end

  def all_lists
    sql = <<~SQL
    SELECT lists.*,
           COUNT(todos.list_id) AS todos_count,
           COUNT(NULLIF(todos.completed, true)) AS todos_remaining_count
         FROM lists
         LEFT JOIN todos ON todos.list_id = lists.id
         GROUP BY lists.id
         ORDER BY lists.name;
    SQL
    result = query(sql)

    result.map do |tuple|
      tuple_to_list_hash(tuple)
    end
  end

  def create_new_list(list_name)
    query("INSERT INTO lists (name) VALUES ($1)", list_name)
  end

  def delete_list(id)
    query("DELETE FROM todos WHERE list_id = $1", id)
    query("DELETE FROM lists WHERE id = $1", id)
  end

  def update_list_name(id, new_name)
    sql = "UPDATE lists SET name = $1 WHERE id = $2"
    query(sql, new_name, id)
  end

  def create_new_todo(list_id, todo_name)
    query("INSERT INTO todos (name, list_id) VALUES ($1, $2)", todo_name, list_id)
  end

  def delete_todo_from_list(list_id, todo_id)
    query("DELETE FROM todos WHERE id = $1 AND list_id = $2", todo_id, list_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
    query(sql, new_status, todo_id, list_id)
  end

  def mark_all_todos_completed(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end

  def find_todos_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
    # this will return PG result object that contains data for every row in todos table with matching list_id
    todos_result = query(todo_sql, list_id)

    todos_result.map do |todo_tuple|
      { id: todo_tuple["id"].to_i,
        name: todo_tuple["name"],
        completed: todo_tuple["completed"] == "t" } # this solves our issue in string "t" from DB vs. boolean in Ruby.
    end
  end

  private

  def tuple_to_list_hash(tuple)
    # we need to convert 'result' into hash that our app requires to load data
    #   hash with symbol keys
    {
      id: tuple["id"].to_i,
      name: tuple["name"],
      todos_count: tuple["todos_count"].to_i,
      todos_remaining_count: tuple["todos_remaining_count"].to_i
    }
  end
end
