class AddApprovedToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :approved, :boolean
  end
end
