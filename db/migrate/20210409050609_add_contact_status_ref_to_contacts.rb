class AddContactStatusRefToContacts < ActiveRecord::Migration[6.1]
  def change
    add_reference :contacts, :contact_status, foreign_key: true, type: :uuid
  end
end
