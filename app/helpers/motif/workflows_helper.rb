module Motif::WorkflowsHelper
  def get_workflows(user, template_type)
    if user.active_outlet.present?
      current_user.active_outlet.workflows.includes(:template).where(templates: {template_type: template_type})
    else
      # For master franchisees, owned outlet workflows are the workflows assigned to master franchisees from the franchisor
      @owned_outlet_workflows = Workflow.includes(outlet: :franchisee).includes(:template).where(outlets: {franchisees: {franchise_licensee: user.company.name}}, templates: { template_type: template_type})
      # For MF to manage
      @sub_franchisee_workflows = Workflow.includes(:template).where(templates: { company_id: user.company.id, template_type: template_type})
      # Combine all the workflows, regardless of blank and present
      @workflows = @owned_outlet_workflows + @sub_franchisee_workflows
      return @workflows
    end
  end
end
