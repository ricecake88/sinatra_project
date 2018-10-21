class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.date :expense_date
      t.decimal :expense_amount, :precision => 8, :scale => 2
      t.string :expense_description
      t.integer :expense_category_id
    end
  end
end
