# This policy authorize only investor company to access investor's dataroom
class Overture::Investors::DocumentPolicy < DocumentPolicy
  def index?
    user.company.investor?
  end
end
