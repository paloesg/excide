class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contact_number, :string
    add_column :users, :allow_contact, :boolean
    add_column :users, :agree_terms, :boolean
  end
end
