module Symphony::InvoicesHelper
  # Check if the invoice has existing xero contact or a new contact. If new, create contact in Xero and in db
  def update_xero_contacts(xero_contact_name, xero_contact_id, invoice, clients)
    if xero_contact_name.blank?
      invoice.xero_contact_name = clients.find_by(contact_id: xero_contact_id).name
    else
      invoice.xero_contact_id = @xero.create_contact(name: xero_contact_name)
      XeroContact.create(name: xero_contact_name, contact_id: invoice.xero_contact_id, company: @company)
    end
    invoice.save
  end

  def redirect_to_next_action(workflow, workflow_action_id)
    workflow_action = WorkflowAction.find(workflow_action_id)
    incomplete_workflows = workflow.batch.workflows.includes(workflow_actions: :task).where(workflow_actions: {tasks: {id: workflow_action.task_id}, completed: false}).order(created_at: :asc)
    incomplete_workflows = incomplete_workflows.includes(:invoice).where.not(invoices: {id: nil}) if params[:action] == "update"

    # Check for workflows with invoice yet action is not completed and set the next workflow
    if incomplete_workflows.count > 0
      next_wf = incomplete_workflows.where('workflows.created_at > ?', workflow.created_at).first
      next_wf = incomplete_workflows.where('workflows.created_at < ?', workflow.created_at).first if next_wf.blank?

      if next_wf.present?
        next_wf_action = next_wf.workflow_actions.where(completed: false).first
        invoice_type = params[:invoice_type].present? ? params[:invoice_type] : next_wf.invoice&.invoice_type
        # if action is not update, redirect to new page, otherwise edit path
        params[:action] == "update" ? (redirect_to edit_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, id: next_wf.invoice.id, workflow_action_id: next_wf_action.id)) : (redirect_to new_symphony_invoice_path(workflow_name: next_wf.template.slug, workflow_id: next_wf.id, invoice_type: invoice_type, workflow_action_id: next_wf_action.id))
      else
        redirect_to symphony_batch_path(batch_template_name: workflow.batch.template.slug, id: workflow.batch.id, notice: "#{workflow_action.task.task_type.humanize}task has been saved")
      end
    else
      redirect_to symphony_batch_path(batch_template_name: workflow.batch.template.slug, id: workflow.batch.id, notice: "#{workflow_action.task.task_type.humanize}task has been completed")
    end
  end
  # Update action to true if it is completed for batches
  def update_workflow_action_completed(workflow_action_id, current_user)
    workflow_action = WorkflowAction.find(workflow_action_id)
    workflow_action.update(completed: true, completed_user_id: current_user.id)
  end

  # Navigate to next invoice or previous invoice depending on which workflow and action are passed in
  def render_action_invoice(workflow, workflow_action)
    if workflow.invoice.blank?
      invoice_type = params[:invoice_type].present? ? params[:invoice_type] : @workflow.invoice&.invoice_type
      redirect_to new_symphony_invoice_path(workflow_name: workflow.template.slug, workflow_id: workflow.friendly_id, invoice_type: invoice_type, workflow_action_id: workflow_action)
    elsif workflow.invoice.present?
      redirect_to edit_symphony_invoice_path(workflow_name: workflow.template.slug, workflow_id: workflow.friendly_id, id: workflow.invoice.id, workflow_action_id: workflow_action)
    end
  end
end
