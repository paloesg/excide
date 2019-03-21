class AddCurrencyToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :currency, :string
  end
end
