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

  def destroy?
    user.has_role? :superadmin and trial_or_pro_only?
  end

  class Scope < Scope
    def resolve
      if user.has_role?(:admin, user.company) or user.has_role? :superadmin
        scope.where(company: user.company)
      else
      # Scope workflow by user has a role in
        scope.where(company: user.company, id: user.relevant_batch_ids)
      end
    end
  end

  private
  def trial_or_pro_only?
    user.company.free_trial? or user.company.pro?
  end
end
