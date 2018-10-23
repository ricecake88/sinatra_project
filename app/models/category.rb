class Category < ActiveRecord::Base
  def self.create_category_if_empty
    if !Category.any?
      cat = Category.new(:category_name => "Expenses")
      Category.all << cat
      cat.save
    end
  end
end
