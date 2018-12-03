class CategoriesUsers < ActiveRecord::Migration
  def change
    create_table :categories_users do |t|
      t.integer :category_id
      t.integer :user_id
    end
  end
end
