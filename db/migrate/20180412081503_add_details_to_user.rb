class AddDetailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :nric, :string
    add_column :users, :bank_name, :string
    add_column :users, :bank_account_number, :string
    add_column :users, :bank_account_type, :integer
    add_column :users, :date_of_birth, :date
    add_column :users, :remarks, :text
  end
end
