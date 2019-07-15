class WorkflowPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    #allow any user with role or assigned task using intersection from user role and workflow task role. Admin gets to see all the workflows!
    (user.get_role_ids & record.get_task_role_ids).any? or user_admin?
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

  def destroy?
    user_admin?
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
    user_admin?
  end

  def archive?
    update?
  end

  def stop_reminder?
    update?
  end

  def reset?
    user_admin?
  end

  def activities?
    update?
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
      if user.has_role?(:admin, user.company)
        scope.all
      else
      # Scope workflow by user has a role in
        scope.where(company: user.company, id: user.relevant_workflow_ids)
      end
    end
  end
  private
  def user_admin?
    user.has_role?(:admin, record.company)
  end
end
