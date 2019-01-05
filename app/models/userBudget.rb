class UserBudget < ActiveRecord::Base
  belongs_to :user
  belongs_to :budget
end
