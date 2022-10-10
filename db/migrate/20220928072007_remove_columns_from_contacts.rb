class RemoveColumnsFromContacts < ActiveRecord::Migration[6.1]
  def change
    remove_column :contacts, :phone, :string
    remove_column :contacts, :email, :string
    remove_column :contacts, :company_name, :string
  end
end
