class AddTotalToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :total, :decimal
  end
end
