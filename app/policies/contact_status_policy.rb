class ContactStatusPolicy < ApplicationPolicy
  def index?
    company_startup?
  end

  class Scope < Scope
    def resolve
      # Scope contacts from the user's company
      scope.where(company: user.company)
    end
  end

  private
  def company_startup?
    # Check if company is a startup before accessing the investor profile or the search page
    user.company.startup?
  end
end
