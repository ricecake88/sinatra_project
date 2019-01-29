require 'date'
class User < ActiveRecord::Base
  has_many :categories
  validates_presence_of :username, :password
  has_secure_password


  def expenses
    expenses = []
    self.categories.each do |cat|
      expenses.append(cat.expenses)
    end
    expenses.flatten
  end

  def budgets
    budgets = []
    self.categories.each do |cat|
      budgets << cat.budget
    end
    budgets
  end

  def categories_sorted
    self.categories.sort_by &:category_name
  end

  def specific_month_expenses(desired_year, desired_month)
    expenses = []
    expenses = self.expenses.select {
      |e| e.date.strftime("%m").to_i == desired_month && e.date.strftime("%Y").to_i
    }
    expenses = expenses.sort_by(&:date)
    return expenses
  end

  def expenses_previous_month(current_year, current_month)
    expenses = []
    if Helpers.current_month == 1
      month = 12
      year = current_year - 1
    else
      month = Helpers.current_month - 1
      year = current_year
    end
    expenses = self.specific_month_expenses(year, month)
    return expenses
  end


  def total_current_month
    expenses = self.specific_month_expenses(Helpers.current_year, Helpers.current_month)
    amount = 0
    expenses.each do |e|
      amount+= e.amount
    end
    return amount
  end

  def total_current_month_by_category(category_id)
    total_in_category = 0
    expenses = self.specific_month_expenses(Helpers.current_year, Helpers.current_month)
    expenses.each do |e|
      if e.category_id == category_id
        total_in_category += e.amount
      end
    end
    return total_in_category
  end

  def total_previous_month_by_category(category_id)
    prev_total_in_category = 0
    expenses = self.expenses_previous_month(Helpers.current_year, Helpers.current_month)
    expenses.each do |e|
      if e.category_id == category_id
        prev_total_in_category += e.amount
      end
    end
    return prev_total_in_category
  end

  def surplus_for_category(category_id)
    budget = Budget.find_by(:category_id => category_id)
    total_curr_month = self.total_current_month_by_category(category_id)
    total_prev_month = self.total_previous_month_by_category(category_id)
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
