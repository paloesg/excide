class AddCompanyToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :company, foreign_key: true
  end
end
