class CreateUserBudgets < ActiveRecord::Migration
  def change
    create_table :user_budgets do |t|
      t.integer :user_id
      t.integer :budget_id
    end
  end
end
