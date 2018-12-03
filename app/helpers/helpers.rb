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
    binding.pry
    categories = Category.find_every(:user_id => user.id)
    if !categories.nil?
      categories.each do |cat|
        Expense.all.each do |e|
          if cat.id == e.cat_id
            @expenses << e
          end
        end
      end
    end
  end

end
