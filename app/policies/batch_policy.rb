class BatchPolicy < ApplicationPolicy
  def index?
    user.present? and trial_or_pro_only?
  end

  def show?
    user.company == record.company and trial_or_pro_only?
  end

   def create?
    user.present? and trial_or_pro_only?
  end

  def new?
    create?
  end

  def update?
    user == record.user or user.has_role?(:admin, record.company) and trial_or_pro_only?
  end

  def edit?
    update? 
  end

  def load_batch?
    user.present? and trial_or_pro_only?
  end

  def destroy?
    user.has_role? :superadmin and trial_or_pro_only?
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
