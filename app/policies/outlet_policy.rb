class OutletPolicy < ApplicationPolicy
  def edit?
    # Only give access to company where franchisee belongs to that company
    show?
  end

  def update?
    show?
  end

  def show?
    # Only allow access to the outlet's company and the franchisee's parent company
    record.company == user.company or record.franchisee.parent_company = user.company
  end

  class Scope < Scope
    def resolve
      # Scope outlet from the user's company
      scope.where(company: user.company)
    end
  end
end
