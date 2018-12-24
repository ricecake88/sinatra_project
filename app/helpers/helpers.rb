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

  def self.current_month()
    d = DateTime.now
    d.strftime("%m").to_i
  end

  def self.current_year()
    d = DateTime.now
    d.strftime("%Y").to_i
  end

end
