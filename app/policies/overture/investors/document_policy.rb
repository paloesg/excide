class Overture::Investors::DocumentPolicy < DocumentPolicy
  # This policy authorize only investor company to access investor's dataroom
  def index?
    user.company.investor?
  end
end
