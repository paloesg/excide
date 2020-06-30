class ChangeClientIdToUuid < ActiveRecord::Migration[6.0]
  def change
  	# remove the old foreign_key
    remove_foreign_key :events, :clients
    add_column :clients, :uuid, :uuid, default: "gen_random_uuid()", null: false
    # Add temporary uuid column for associated model
    add_column :events, :client_uuid, :uuid

    Client.find_each do |client|
      Event.where(client_id: client.id).find_each do |event|
        event.client_uuid = client.uuid
        event.save!
      end
    end

    remove_reference :events, :client

    change_table :clients do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE clients ADD PRIMARY KEY (id);"
    rename_column :events, :client_uuid, :client_id

    add_foreign_key :events, :clients
  end
end
