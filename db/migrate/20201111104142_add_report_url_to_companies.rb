class AddReportUrlToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :report_url, :string
  end
end
