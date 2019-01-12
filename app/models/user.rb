class User < ActiveRecord::Base
  #has_many :user_expenses
  #has_many :user_budgets
  has_many :categories
  #has_many :expenses, through: :user_expenses
  #has_many :budgets, through: :user_budgets
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

end
