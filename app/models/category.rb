class Category < ActiveRecord::Base
  def self.create_category_if_empty(sessionName)
    binding.pry
    user = Helpers.current_user(sessionName)
    if !Category.any?
      cat = Category.new(:category_name => "Expenses", :user_id => user.id)
      Category.all << cat
      cat.save
    end
  end
end
