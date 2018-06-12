require "pg"

class DatabasePersistance

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

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    # we need to convert 'result' into hash that our app requires to load data
    #   hash with symbol keys
    tuple = result.first
    {id: tuple["id"], name: tuple["name"], todos: []}
  end

  def all_lists
    sql = "SELECT * FROM lists;"
    result = query(sql)

    result.map do |tuple|
      {id: tuple["id"], name: tuple["name"], todos: []}
    end
  end

  def create_new_list(list_name)
    # id = next_element_id(@session[:lists])
    # @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def delete_list(id)
    # @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list_name(id, new_name)
    # list = find_list(id)
    # list[:name] = new_name
  end

  def create_new_todo(list_id, todo_name)
    # list = find_list(list_id)
    # id = next_element_id(list[:todos])
    # list[:todos] << { id: id, name: todo_name, completed: false }
  end

  def delete_todo_from_list(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, new_status)
    # list = find_list(list_id)
    # # originally used todo inside our block, but due to variable shadowing, we decided to use t
    # todo = list[:todos].find { |t| t[:id] == todo_id }
    # todo[:completed] = new_status
  end

  def mark_all_todos_completed(list_id)
    # list = find_list(list_id)
    # list[:todos].each do |todo|
    #   todo[:completed] = true
    # end
  end

end
