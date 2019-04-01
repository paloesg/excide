class AddXeroContactIdToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :xero_contact_id, :string
  end
end
