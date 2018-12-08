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
    categories_user = []
    categories_user = Category.where(:user_id => user.id)
    if !categories_user.nil?
      Expense.all.each do |expense|
        if categories_user.ids.include?(expense.category_id)
          @expenses << expense
        end
      end
    end
    @expenses
  end

end
