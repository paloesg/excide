class AddInvoiceReferenceToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :invoice_reference, :string
  end
end
