class AddRemarkToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :remarks, :string
  end
end
