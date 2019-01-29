class Category < ActiveRecord::Base
  belongs_to :user
  has_many :expenses
  has_one :budget

  def self.create_category_if_empty(current_user)
    if Category.find_by(:user_id => current_user.id).nil?
      category = Category.new(:category_name => "Expenses")
      category.user = current_user
      current_user.categories << category
      Category.all << category
      category.save
    end
  end

end
