class Helpers
  def self.current_user(sessName)
      @user = User.find(sessName[:user_id])
  end

  def self.is_logged_in?(sessName)
    if sessName[:user_id].nil?
      false
    else
      true
    end
  end

  def self.expenses_for_user(user)
    @expenses = []
    categories_users = []
    categories = Category.all
    if !categories.nil?
      categories.each do |cat|
        if cat.user_id = user.id
          categories_users << cat
        end
      end
      Expense.all.each do |expense|
        if expense.category_id == cat.id
          @expenses << expense
        end
      end
    end
    @expenses
  end

end
