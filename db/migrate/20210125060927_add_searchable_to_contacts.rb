class AddSearchableToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :searchable, :boolean
  end
end
