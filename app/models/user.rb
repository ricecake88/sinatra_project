class User < ActiveRecord::Base
  has_many :user_expenses
  has_many :expenses, through: :user_expenses
end
