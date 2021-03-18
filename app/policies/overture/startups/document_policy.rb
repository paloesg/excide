# This policy authorize only investor company to access startups's dataroom
class Overture::Startups::DocumentPolicy < DocumentPolicy
  def index?
    user.company.startup?
  end
end
