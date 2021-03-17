class Overture::CompanyPolicy < CompanyPolicy
  def index?
    user.company.investor?
  end
end
