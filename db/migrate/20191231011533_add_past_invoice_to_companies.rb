class AddPastInvoiceToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :past_invoice, :json, default: []
  end
end
