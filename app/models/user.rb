class User < ActiveRecord::Base
  #has_many :user_expenses
  #has_many :user_budgets
  has_many :categories
  #has_many :expenses, through: :user_expenses
  #has_many :budgets, through: :user_budgets
  validates_presence_of :username, :password
  has_secure_password
end
