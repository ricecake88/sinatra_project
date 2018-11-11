class CreateBudgetExpenses < ActiveRecord::Migration
  def change
    create_table :expenses_users do |t|
      t.integer :expense_id
      t.integer :user_id
    end
  end
end
