class Expense < ActiveRecord::Base
    belongs_to :expenses
    belongs_to :users
end
