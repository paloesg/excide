class AddWorkflowActionToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :workflow_action, foreign_key: true
  end
end
