class AddXeroContactIdToClient < ActiveRecord::Migration
  def change
    add_column :clients, :xero_contact_id, :string
  end
end
