class BatchPolicy < ApplicationPolicy
  def index?
    user.present? and trial_or_pro_only?
  end

  def show?
    user.company == record.company
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

  def load_batch?
    user.present?
  end

  def destroy?
    user.has_role? :superadmin
  end

  class Scope < Scope
    def resolve
      # Scope Batch by company where user in same company
      scope.where(company: user.company)
    end
  end

  private
  def trial_or_pro_only?
    user.company.free_trial? or user.company.pro?
  end
end
