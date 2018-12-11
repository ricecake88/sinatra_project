class Budget < ActiveRecord::Base
    belongs_to :category

    def self.budgets_for_user(sessionName)
      @budgets = []
      categories_user = Category.categories_of_user(sessionName)
      if !categories_user.nil?
        Budget.all.each do |b|
          if categories_user.ids.include?(b.category_id)
            @budgets << b
          end
        end
      end
      @budgets
    end
end
