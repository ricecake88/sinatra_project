class AddRolloverToBudget < ActiveRecord::Migration
  def self.up
    add_column :budgets, :rollover, :boolean
  end
end
