class AddXeroInvoiceIdToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :xero_invoice_id, :string
  end
end
