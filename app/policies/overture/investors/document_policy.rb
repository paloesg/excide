class Overture::Investors::DocumentPolicy < DocumentPolicy
  def index?
    user.company.investor?
  end
end
