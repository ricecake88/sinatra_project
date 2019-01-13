require 'date'

class Expense < ActiveRecord::Base
    belongs_to :category

    def self.specific_month_expenses(desired_year, desired_month, sessionName)
      expenses = []
      user = Helpers.current_user(sessionName)
      expenses = user.expenses.select {
        |e| e.date.strftime("%m").to_i == desired_month && e.date.strftime("%Y").to_i
      }
      return expenses
    end

    def self.expenses_previous_month(current_year, current_month, sessionName)
      expenses = []
      if Helpers.current_month == 1
        month = 12
        year = current_year - 1
      else
        month = Helpers.current_month - 1
        year = current_year
      end
      expenses_previous_month = self.specific_month_expenses(year, month, sessionName)
      return expenses
    end


    def self.total_current_month(sessionName)
      expenses = Expense.specific_month_expenses(Helpers.current_year, Helpers.current_month, sessionName)
      amount = 0
      expenses.each do |e|
        amount+= e.amount
      end
      return amount
    end

    def self.total_current_month_by_category(sessionName, category_id)
      total_in_category = 0
      user = Helpers.current_user(sessionName)
      category = user.categories.detect {|cat| cat.id == category_id }
      category.expenses.each do |e|
        if e.category_id == category_id
          total_in_category += e.amount
        end
      end
      return total_in_category
    end

    def self.total_previous_month_by_category(sessionName, category_id)
      prev_total_in_category = 0
      expenses = Expense.expenses_previous_month(Helpers.current_year(), Helpers.current_month, sessionName)
      expenses.each do |e|
        if e.category_id == category_id
          prev_total_in_category += e.amount
        end
      end
      return prev_total_in_category
    end
end
