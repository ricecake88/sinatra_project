class Expense < ActiveRecord::Base
    has_many :categories

    def self.total_expenses_for_user(expenses)
      total = 0
      expenses.each do
        total+=expense.amount
      end
    end
end
