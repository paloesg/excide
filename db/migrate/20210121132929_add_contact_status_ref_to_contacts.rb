class AddContactStatusRefToContacts < ActiveRecord::Migration[6.0]
  def change
    add_reference :contacts, :contact_status, type: :uuid, foreign_key: true
    add_column :contacts, :public, :boolean
  end
end
