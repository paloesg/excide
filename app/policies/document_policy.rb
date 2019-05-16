class DocumentPolicy < ApplicationPolicy
  def index?
    false
  end

  def show?

  end

  def create?
    true
  end

  def new?
    true
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role? :admin, record.company
  end

  class Scope < Scope
    def resolve
      # Scope documents by workflows where user has a role in and documents without a workflow.
      scope.where(company: user.company, workflow: user.relevant_workflow_ids + [nil])
    end
  end
end
