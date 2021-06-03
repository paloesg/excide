class Overture::InvestmentPolicy < ApplicationPolicy
  def create?
    if user.company.pro?
      true
    else
      user.company.investor_progress < 100
    end
  end
end
