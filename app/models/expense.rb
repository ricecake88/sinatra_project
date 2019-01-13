require 'date'

class Expense < ActiveRecord::Base
    belongs_to :category
end
