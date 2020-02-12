class RecurringWorkflowPolicy < ApplicationPolicy
  def index?
    trial_or_pro_only?
  end

  def create?
    trial_or_pro_only?
  end

  def new?
    create?
  end

  def update?
    trial_or_pro_only?
  end

  def edit?
    update?
  end

  def show?
    trial_or_pro_only?
  end

  def stop_recurring?
    trial_or_pro_only?
  end

  def trigger_workflow?
    trial_or_pro_only?
  end

  class Scope < Scope
    def resolve
      # Scope recurring workflows from the user's company
      scope.where(company: user.company)
    end
  end

  private
  def trial_or_pro_only?
    user.company.free_trial? or user.company.pro?
  end
end
