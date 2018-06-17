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

.
