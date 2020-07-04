class ChangeEventIdToUuid < ActiveRecord::Migration[6.0]
  def change
		# remove the old foreign_key
    remove_foreign_key :events, :clients
	  remove_foreign_key :allocations, :events
	  add_column :events, :uuid, :uuid, default: "gen_random_uuid()", null: false
	  # Add temporary uuid column for associated model
	  add_column :allocations, :event_uuid, :uuid

	  Event.find_each do |event|
	    Allocation.where(event_id: event.id).find_each do |allocation|
	      allocation.event_uuid = event.uuid
	      allocation.save!
	    end
	  end

	  remove_reference :allocations, :event

	  change_table :events do |t|
	    t.remove :id
	    t.rename :uuid, :id
	  end
	  execute "ALTER TABLE events ADD PRIMARY KEY (id);"
	  rename_column :allocations, :event_uuid, :event_id

	  add_foreign_key :allocations, :events
  end
end
