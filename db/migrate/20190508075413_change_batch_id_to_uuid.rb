class ChangeBatchIdToUuid < ActiveRecord::Migration[5.2]
	def change
	     enable_extension 'uuid-ossp'
	     add_column :batches, :uuid, :uuid, default: "uuid_generate_v4()", null: false

	   change_table :batches do |t|
	     t.remove :id
	     t.rename :uuid, :id
	   end
	   execute "ALTER TABLE batches ADD PRIMARY KEY (id);"
	end
end
