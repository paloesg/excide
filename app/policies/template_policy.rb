class TemplatePolicy < ApplicationPolicy
  def index?
    user_admin_or_franchisor?
  end

  def create?
    user_admin_or_franchisor?
  end

  def new?
    create?
  end

  def update?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    create?
  end
  
  def destroy_section?
    create?
  end

  def check_template?
    #If user's company matches the template's company, allow authorization usage of template when creating new workflows. Also, record.company.nil? accounts for when the template is a general template for cloning.
    # If task type is pro, it will be selected and inside the section array. Since it is a nested array, we flatten it and if its empty, it does not contain any pro task type. This check happens if company is basic.
    (user.company == record.company or record.company.nil?) && (user.company.basic? ? (record.sections.map {|s| s.tasks.select {|t| t.task_type == "create_invoice_payable"|| t.task_type == "xero_send_invoice" || t.task_type == "create_invoice_receivable"|| t.task_type == "coding_invoice"}}.flatten.empty?) : true)
  end

  class Scope < Scope
    def resolve
      # Scope templates from the user's company
      scope.where(company: user.company)
    end
  end

  private
  def user_admin_or_franchisor?
    user.has_role?(:admin, user.company) or user.has_role? :superadmin or user.has_role?(:franchisor, user.company)
  end
end
