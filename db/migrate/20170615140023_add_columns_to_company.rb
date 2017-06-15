class AddColumnsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :ssic_code, :string
    add_column :companies, :financial_year_end, :date
  end
end
