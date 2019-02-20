class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.string :invoice_identifier
      t.datetime :invoice_date
      t.datetime :due_date
      t.json :lineitems, default: []

      t.timestamps
    end
  end
end