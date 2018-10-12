class Expense < ActiveRecord::Base
    has_many :categories
end