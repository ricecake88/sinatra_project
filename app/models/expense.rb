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
        Expense.all.each do |expense|
          if categories_user.ids.include?(expense.category_id)
            @expenses << expense
          end
        end
      end
      @expenses
    end

    def self.expenses_by_user_category(sessionName, category_id)
      @expenses = Expense.where(:category_id => category_id)
    end

    def self.expenses_last_30_days(sessionName)
      @expenses = Expense.expenses_for_user(sessionName)
    end

    def self.expense_by_month(month)
    end

    def self.expenses_current_month(desired_year, desired_month, sessionName)
      Expense.where("cast(strftime('%Y', date) as int) = ?", desired_year)
      expenses = []
      expenses_current_month = Expense.where("cast(strftime('%m', date) as int) = ? and cast(strftime('%Y', date) as int) = ?", desired_month, desired_year)
      expenses_by_user = Expense.expenses_for_user(sessionName)
      expenses_current_month.each do |e_cm|
        expenses_by_user.each do |e_u|
          if e_cm.id == e_u.id
            expenses << e_cm
          end
        end
      end
      #Expense.where("cast(strftime('%d', date) as int) = ?", desired_day_of_month)
    end

end
