class WorkflowPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    #allow any user with role or assigned task using intersection from user role and workflow task role
    (user.get_role_ids & record.get_task_role_ids).present?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    (user.get_role_ids & record.get_task_role_ids).present? or user.has_role?(:admin, record.company)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role? :admin, record.company
  end

  def toggle?
    update?
  end

  def toggle_all?
    update?
  end

  def assign?
    update?
  end

  def send_reminder?
    user.has_role? :admin, record.company
  end

  def archive?
    update?
  end

  def stop_reminder?
    update?
  end

  def reset?
    user.has_role? :admin, record.company
  end

  def activities?
    show?
  end

  def data_entry?
    update?
  end

  def xero_create_invoice_payable?
    update?
  end

  def send_email_to_xero?
    update?
  end

  class Scope < Scope
    def resolve
      # Scope workflow by user has a role in
      scope.where(company: user.company, id: user.relevant_workflow_ids)
    end
  end
end
