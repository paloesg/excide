class AddReferenceToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :reference, :string
  end
end
