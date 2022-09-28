class AddDetailsToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :industry, :integer
    add_column :contacts, :year_founded, :integer
    add_column :contacts, :country_of_origin, :string
    add_column :contacts, :markets_available, :string
    add_column :contacts, :franchise_fees, :string
    add_column :contacts, :average_investment, :string
    add_column :contacts, :royalty, :string
    add_column :contacts, :marketing_fees, :string
    add_column :contacts, :renewal_fees, :string
    add_column :contacts, :franchisor_tenure, :string
  end
end
