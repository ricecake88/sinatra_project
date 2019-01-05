class Category < ActiveRecord::Base
  belongs_to :user

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

  def self.categories_of_user(sessionName)
    user = Helpers.current_user(sessionName)
    categories = Category.where(:user_id => user.id)
  end
end
