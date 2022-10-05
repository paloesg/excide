class AddBackColsForLeadsManagement < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :phone, :string
    add_column :contacts, :email, :string
    add_column :contacts, :company_name, :string
  end
end
