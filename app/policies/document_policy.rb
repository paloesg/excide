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

  def index_create?
    create?
  end

  def multiple_edit?
    index?
  end

  def destroy?
    user.has_role? :admin, record.company
  end

  class Scope < Scope
    def resolve
      # Scope documents by workflows where user has a role in and documents without a workflow and those that have an ActiveStorage attachment.
      scope.where(company: user.company, workflow: user.relevant_workflow_ids + [nil]).joins(:raw_file_attachment)
    end
  end
end
