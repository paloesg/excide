class AddXeroContactIdToClient < ActiveRecord::Migration[4.2]
  def change
    add_column :clients, :xero_contact_id, :string
  end
end
