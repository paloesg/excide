module Motif::WorkflowsHelper
  # get_workflows method retrieves all workflows (from franchised or direct owned outlets) and it is not restricted by company
  # Get workflows based on template_type for workflow INDEX
  def get_workflows(user, template_type)
    if user.active_outlet.present?
      current_user.active_outlet.workflows.includes(:template).where(templates: {template_type: template_type})
    else
      # For direct owned outlet's workflows
      owned_outlet_workflows = user.company.workflows
      # For getting franchised outlet's workflows
      franchised_outlet_workflows = user.company.parent.present? ? user.company.parent.workflows.includes(:outlet).where(outlets: { company_id: user.company.id }) : []
      # Combine all the workflows, regardless of blank and present
      @workflows = owned_outlet_workflows + franchised_outlet_workflows
      return @workflows
    end
  end
end
