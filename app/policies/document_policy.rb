class DocumentPolicy < ApplicationPolicy
  def index?
    user.present?
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
