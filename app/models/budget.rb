class Budget < ActiveRecord::Base
    belongs_to :category
    belongs_to :user

    def self.surplus_for_category(sessionName, category_id)
      budget = Budget.find_by(:category_id => category_id)
      total_curr_month = Expense.total_current_month_by_category(sessionName, category_id)
      total_prev_month = Expense.total_previous_month_by_category(sessionName, category_id)
      leftover = 0.0
      curr_leftover = 0.0
      amount = 0.0
      if !budget.nil?
        amount = budget.amount
        if budget.rollover
          leftover = budget.amount - total_prev_month
          if leftover > 0
            curr_leftover = budget.amount - total_curr_month + leftover
          end
        else
          curr_leftover = budget.amount - total_curr_month
        end
      end
      return {"cat_id": category_id, "budget": amount, "total_curr_month": total_curr_month, "total_prev_month": total_prev_month, "leftover": leftover, "current_leftover": curr_leftover}
    end

end
