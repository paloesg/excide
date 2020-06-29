class ChangeInboundEmailIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :action_mailbox_inbound_emails, :uuid, :uuid, default: "gen_random_uuid()", null: false
  	
  	change_table :action_mailbox_inbound_emails do |t|
      t.remove :id
      t.rename :uuid, :id
    end

    execute 'ALTER TABLE action_mailbox_inbound_emails ADD PRIMARY KEY (id);'
  end
end
