############################ DECLARATIVE LANGUAGE #############################

- SQL statement: describes 'what' to do but now 'how'.
- PostgreSQL determines best way to perform statement.
- Downside: querying in an inefficient way.
- Solution? can provide requirements about how to execute a query.
            'Database Optimization'

######################## HOW POSTGRESQL EXECUTES QUERY ########################


Our example -> 'SELECT' query breakdown

1) Rows are collected into a virtual derived 'temp' table using data from 'FROM'
     clause (includes 'JOIN' clauses).

2) Rows are filtered using 'WHERE' conditions
     All conditions in 'WHERE' clause are evaluated for each row, those that dont match are removed.

3) Rows are divided into groups ('GROUP BY' clause)
     If 'GROUP BY' exists, remaining rows are divided into groups.

4) Rows are filtered using 'HAVING' conditions
   - applied to values that are used to create groups vs. 'WHERE' conditions which occurs on rows.
   - column in 'HAVING' clause almost always needs to appear in 'GROUP BY' and/or
     an aggregate function in the same query.
   - both 'GROUP BY' and aggregate functions perform grouping, 'HAVING' clause is used
       to filter that aggregated/grouped data.

5) Compute values to return using select list. Each element in the select list is evaluated,
     including any functions, and the resulting values are associated with the name of the col.
     they are from or the name of the last function evaluated unless a different name is specied
     with 'AS'

6) Sort Results. Sorted as specified by 'ORDER BY' clause. If not specified, result
     returned in an order that is the result of how the DB executed the query and rows
     order in original tables.

7) Limit Results. If 'LIMIT' or 'OFFSET' clauses are included, they are used to adjust rows.

# FURTHER EXPLANATION - DOCUMENTATION
# https://www.postgresql.org/docs/9.5/static/query-path.html
