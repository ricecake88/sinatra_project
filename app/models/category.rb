class Category < ActiveRecord::Base
  belongs_to :user
  belongs_to :budget
  has_many :expenses

  def self.create_category_if_empty(sessionName)
    user = Helpers.current_user(sessionName)
    if Category.find_by(:user_id => user.id).nil?
      cat = Category.new(:category_name => "Expenses")
      cat.user = user
      user.categories << cat
      Category.all << cat
      cat.save
    end
  end

  def self.sort_categories(sessionName)
    categories = Helpers.current_user(sessionName).categories
    categories.sort_by &:category_name
  end
end
