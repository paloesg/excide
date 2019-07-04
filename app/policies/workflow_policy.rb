class WorkflowPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    #allow any user with role or assigned task using intersection from user role and workflow task role
    user.get_role_ids & record.get_task_role_ids
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.get_role_ids & record.get_task_role_ids
  end

  def edit?
    update?
  end

  def assign?
    update?
  end

  def archive?
    update?
  end

  def reset?
    update?
  end

  def activities?
    show?
  end

  def destroy?
    user.has_role? :admin, record.company
  end

  class Scope < Scope
    def resolve
      # Scope workflow by user has a role in
      scope.where(company: user.company, id: user.relevant_workflow_ids)
    end
  end
end
