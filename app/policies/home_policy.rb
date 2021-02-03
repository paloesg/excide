class HomePolicy < Struct.new(:user, :home)
  def capitalization_table?
    company_startup?
  end

  private
  def company_startup?
    # Check if company is a startup before accessing the investor profile or the search page
    user.company.startup?
  end
end
