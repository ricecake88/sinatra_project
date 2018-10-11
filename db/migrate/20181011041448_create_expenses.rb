class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.date :expense_date
      t.string :expense_amount
      t.string :expense_description
      t.integer :expense_category
    end
  end
end
