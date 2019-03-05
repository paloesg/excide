class AddLineAmountTypesToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :line_amount_type, :integer
  end
end