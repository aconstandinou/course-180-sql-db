#! /usr/bin/env ruby

require "pg"
require "io/console"

class ExpenseData
  attr_accessor :connection

  def initialize
    @connection = PG.connect(dbname: "expenses")
  end

  def add_expense(amount, memo)
    date = Date.today

    sql = "INSERT INTO expenses (amount, memo, created_on) VALUES ($1, $2, $3)"
    connection.exec_params(sql, [amount, memo, date])
  end

  def list_expenses
    result = connection.exec "SELECT * FROM expenses;"
    display_count(expenses)
    display_expenses(result) if result.ntuples > 0
  end

  def search_expenses(memo_search)
    sql = "SELECT * FROM expenses WHERE memo ILIKE $1"
    result = connection.exec_params(sql, [memo_search])
    display_count(result)
    display_expenses(result) if result.ntuples > 0
  end

  def delete_expense(row_id)
    sql = "SELECT * FROM expenses WHERE id = $1"
    result = connection.exec_params(sql, [row_id])

    if result.ntuples == 0
      puts "There is no expense with the id '#{row_id}'."
    else
      puts "The following expense has been deleted:"
      display_expenses(result)
      sql = "DELETE FROM expenses WHERE id = $1"
      result = connection.exec_params(sql, [row_id])
    end

  end

  def display_expenses(expenses)
    total = 0.0
    expenses.each do |tuple|
      columns = [ tuple["id"].rjust(3),
                  tuple["created_on"].rjust(10),
                  tuple["amount"].rjust(12),
                  tuple["memo"] ]
      total += tuple["amount"].to_f
      puts columns.join(" | ")
    end
    puts "-" * 50
    puts "Total " + total.to_s.rjust(25)
  end

  def delete_all_rows
    puts "All expenses have been deleted."
    sql = "DELETE FROM expenses"
    connection.exec(sql)
  end

  def display_count(result)
    count = expenses.ntuples
    if count == 0
      puts "There are no expenses."
    elsif count == 1
      puts "There is #{count} expense."
    else
      puts "There are #{count} expenses."
    end
  end

end

class CLI

  def initialize
    @application = ExpenseData.new
  end

  def run (arguments)
    command = arguments.shift
    case command

    when "add"
      amount = arguments[0]
      memo = arguments[1]
      abort "You must provide an amount and memo." unless amount && memo
      @application.add_expense(amount, memo)
    when "list"
      @application.list_expenses
    when "search"
      criteria = arguments[0]
      @application.search_expenses(criteria)
    when "delete"
      row_id = arguments[0]
      @application.delete_expense(row_id)
    when "clear"
      puts "This will remove all expenses. Are you sure? (y/n)"
      response = $stdin.getch
      @application.delete_all_rows if response == "y"
    else
      display_help
    end
  end

  def display_help
    puts <<~HELP
      An expense recording system

      Commands:

      add AMOUNT MEMO [DATE] - record a new expense
      clear - delete all expenses
      list - list all expenses
      delete NUMBER - remove expense with id NUMBER
      search QUERY - list expenses with a matching memo field
    HELP
  end

end

CLI.new.run(ARGV)
