class PostPolicy < ApplicationPolicy
  def create?
    user.company.startup?
  end

  def show?
    user.company = record.company
  end

  def update?
    user = record.author
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  class Scope < Scope
    def resolve
      if user.company.startup?
        scope.where(company: user.company)
      elsif user.company.investor?
        scope.where(company: user.company.investor_investments)
      end
    end
  end
end
