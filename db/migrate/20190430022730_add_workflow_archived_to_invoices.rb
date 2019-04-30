class AddWorkflowArchivedToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :workflow_archived, :boolean
  end
end
