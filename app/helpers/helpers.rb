class Helpers
  def self.current_month()
    d = DateTime.now
    d.strftime("%m").to_i
  end

  def self.current_year()
    d = DateTime.now
    d.strftime("%Y").to_i
  end

end
