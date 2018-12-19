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
    end

    def self.expense_by_month(month)

end
