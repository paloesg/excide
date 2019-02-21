class CreateInvoice < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices, id: :uuid do |t|
      t.string :invoice_identifier
      t.date :invoice_date
      t.date :due_date
      t.json :lineitems, default: []

      t.timestamps
    end
  end
end