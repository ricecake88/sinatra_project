class Expense < ActiveRecord::Base
    has_many :user_expenses
    belongs_to :user

    def self.expenses_current_month(desired_year, desired_month, sessionName)
      expenses = []
      expenses_current_month = Expense.where("cast(strftime('%m', date) as int) = ? and cast(strftime('%Y', date) as int) = ?", desired_month, desired_year).order(date: :asc)
      expenses_current_month.each do |expense|
        if expense.user_id == Helpers.current_user(sessionName).id
          expenses << expense
        end
      end
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
      expenses_previous_month = Expense.where("cast(strftime('%m', date) as int) = ? and cast(strftime('%Y', date) as int) = ?", month, year).order(date: :asc)
      expenses_previous_month.each do |expense|
        if expense.user_id == Helpers.current_user(sessionName).id
          expenses << expense
        end
      end
      return expenses
    end


    def self.total_current_month(sessionName)
      expenses = Expense.expenses_current_month(Helpers.current_year, Helpers.current_month, sessionName)
      amount = 0
      expenses.each do |e|
        amount+= e.amount
      end
      return amount
    end

    def self.total_current_month_by_category(sessionName, category_id)
      total_in_category = 0
      expenses = Expense.expenses_current_month(Helpers.current_year(), Helpers.current_month, sessionName)
      expenses.each do |e|
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
