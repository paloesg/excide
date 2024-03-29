class InvoicePolicy < ApplicationPolicy
  def show?
    (user == record.user) or user.has_role?(:associate, record.company) or user.has_role?(:admin, record.company) or user.has_role?(:shared_service, record.company)
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    show?
  end

  def edit?
    update?
  end

  def reject?
    user.has_role?(:shared_service, :any) or user.has_role?(:admin, :any) or user.has_role?(:consultant, :any)
  end

  def destroy?
    user.has_role?(:associate, record.company) or user.has_role?(:admin, record.company)
  end

  class Scope < Scope
    def resolve
      # Scope invoices by user who created the invoices
      if user.has_role?(:admin, record.company)
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
