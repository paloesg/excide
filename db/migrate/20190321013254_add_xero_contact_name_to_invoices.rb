class AddXeroContactNameToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :xero_contact_name, :string
  end
end
