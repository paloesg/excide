module Motif::WorkflowsHelper
  # get_workflows method retrieves all workflows (from franchised or direct owned outlets) and it is not restricted by company
  # Get workflows based on template_type for workflow INDEX
  def get_workflows(user, template_type)
    if user.active_outlet.present?
      current_user.active_outlet.workflows.includes(:template).where(templates: {template_type: template_type})
    else
      # For direct owned outlet's workflows
      owned_outlet_workflows = user.company.workflows.includes(:template).where(templates: {template_type: template_type})
      # For getting franchised outlet's workflows
      franchised_outlet_workflows = user.company.parent.present? ? user.company.parent.workflows.includes(:outlet, :template).where(templates: {template_type: template_type}, outlets: { company_id: user.company.id }) : []
      # Combine all the workflows, regardless of blank and present
      @workflows = owned_outlet_workflows + franchised_outlet_workflows
      return @workflows
    end
  end

  def disable_checklist(workflow, user)
    # Onboarding, site audit and royalty collection workflows
    if workflow.outlet.present?
      user.has_role?(:franchisee_owner, user.company) or user.company != workflow.company
    # Retrospective workflows
    else
      # If user is management level company (like franchisor), then checkbox should be enabled. Otherwise, for the rest of the franchisee, the checkboxes are disabled
      user.company == workflow.company ? true : false
    end
  end
end
