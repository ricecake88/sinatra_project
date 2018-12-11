class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.decimal :amount, :precision => 8, :scale => 2
      t.integer :category_id
    end
  end
end
