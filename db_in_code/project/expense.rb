#! /usr/bin/env ruby

require "pg"

CONNECTION = PG.connect(dbname: "expenses")

def add_expense(amount, memo)
  date = Date.today

  sql = "INSERT INTO expenses (amount, memo, created_on) VALUES
         (#{amount}, '#{memo}', '#{date}')"

  CONNECTION.exec(sql)
end

def list_expenses
  result = CONNECTION.exec "SELECT * FROM expenses;"

  result.each do |tuple|
    columns = [ tuple["id"].rjust(3),
                tuple["created_on"].rjust(10),
                tuple["amount"].rjust(12),
                tuple["memo"] ]

    puts columns.join(" | ")
  end
end

def explain_method
  puts <<~HELP
    An expense recording system

    Commands:

    add AMOUNT MEMO [DATE] - record a new expense
    clear - delete all expenses
    list - list all expenses
    delete NUMBER - remove expenses with ID number
    search QUERY - list expenses with a matching memo fields
  HELP
end

command, *remaining_args = ARGV

if command == 'list'
  list_expenses
elsif command == "add"
  if remaining_args.size == 2
    amount = ARGV[1]
    memo = ARGV[2]
    add_expense(amount, memo)
  else
    puts "You must provide an amount and memo."
  end
else
  explain_method
end
