class AddClonedByRefToContacts < ActiveRecord::Migration[6.0]
  def change
    add_reference :contacts, :cloned_by, type: :uuid, foreign_key: {to_table: :companies}
  end
end
