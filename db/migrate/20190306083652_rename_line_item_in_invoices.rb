class RenameLineItemInInvoices < ActiveRecord::Migration[5.2]
  def change
    rename_column :invoices, :lineitems, :line_items
  end
end
