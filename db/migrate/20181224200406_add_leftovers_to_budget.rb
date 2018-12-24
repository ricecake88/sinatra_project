class AddLeftoversToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :leftover, :amount, :precision => 8, :scale => 2
  end
end
