class AddSearchableToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :searchable, :boolean, default: false
  end
end
