class AddXeroPropertiesToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :session_handle, :string
    add_column :companies, :access_key, :string
    add_column :companies, :access_secret, :string
    add_column :companies, :expires_at, :integer
  end
end
