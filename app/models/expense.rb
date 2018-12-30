class Expense < ActiveRecord::Base
    has_many :categories

    def self.total_expenses_for_user(expenses)
      total = 0
      expenses.each do |expense|
        total+=expense.amount
      end
      total
    end

    def self.expenses_for_user(sessionName)
      @expenses = []
      categories_user = Category.categories_of_user(sessionName)
      if !categories_user.nil?
        Expense.all.order(date: :asc).each do |expense|
          if categories_user.ids.include?(expense.category_id)
            @expenses << expense
          end
        end
      end
      @expenses
    end

    def self.expenses_by_user_category(sessionName, category_id)
      @expenses = Expense.where(:category_id => category_id).order(date: :desc)
    end

    def self.expenses_last_30_days(sessionName)
      @expenses = Expense.expenses_for_user(sessionName).order(date: :desc)
    end

    def self.expense_by_month(month)
    end

    def self.expenses_current_month(desired_year, desired_month, sessionName)
      expenses = []
      expenses_current_month = Expense.where("cast(strftime('%m', date) as int) = ? and cast(strftime('%Y', date) as int) = ?", desired_month, desired_year).order(date: :desc)
      expenses_by_user = Expense.expenses_for_user(sessionName)
      expenses_current_month.each do |e_cm|
        expenses_by_user.each do |e_u|
          if e_cm.id == e_u.id
            expenses << e_cm
          end
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
      end
      expenses_previous_month = Expense.where("cast(strftime('%m', date) as int) = ? and cast(strftime('%Y', date) as int) = ?", month, year).order(date: :desc)
      expenses_by_user = Expense.expenses_for_user(sessionName)
      expenses_previous_month.each do |e_pm|
        expenses_by_user.each do |e_u|
          if e_pm.id == e_u.id
            expenses << e_pm
          end
        end
      end
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
    end

    def self.total_previous_month_by_category(sessionName, category_id)
      prev_total_in_category = 0
      expenses = Expense.expenses_previous_month(Helpers.current_year(), Helpers.current_month, sessionName)
      expenses.each do |e|
        if e.category_id == category_id
          prev_total_in_category += e.amount
        end
      end
    end
end
