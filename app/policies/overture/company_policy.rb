class Overture::CompanyPolicy < CompanyPolicy
  # This policy covers accessing the potential startups page for investor's dataroom. Should not authorize startup users to access this page
  def index?
    user.company.investor?
  end
end
