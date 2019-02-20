class AddWorkflowRefToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :workflow, foreign_key: true
  end
end
