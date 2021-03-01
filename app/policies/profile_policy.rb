class ProfilePolicy < ApplicationPolicy
  def index?
    show?
  end

  def create?
    user.company = record.company
  end

  def update?
    show?
  end

  def show?
    company_investor?
  end

  class Scope < Scope
    def resolve
      # Scope contacts from the user's company
      scope.all
    end
  end

  private
  def company_investor?
    # Check if company is a startup before accessing the investor profile or the search page
    user.company.investor?
  end
end
