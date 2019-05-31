class InvoicePolicy < ApplicationPolicy
  def show?
    user.company == record.user.company
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user == record.user or user.has_role?(:admin, record.company)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role? :admin, record.user.company
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
