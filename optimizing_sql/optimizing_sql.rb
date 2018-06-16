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








.
