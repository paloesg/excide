class FranchiseePolicy < ApplicationPolicy
  def edit?
    # Only give access to company where franchisee belongs to that company
    show?
  end

  def show?
    user.company == record.parent_company
  end

  class Scope < Scope
    def resolve
      # Scope templates from the user's company
      scope.where(parent_company: user.company)
    end
  end
end
