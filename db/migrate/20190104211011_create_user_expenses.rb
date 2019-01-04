class CreateUserExpenses < ActiveRecord::Migration
  def change
    create_table :user_expenses do |t|
      t.integer :user_id
      t.integer :expense_id
    end
  end
end
