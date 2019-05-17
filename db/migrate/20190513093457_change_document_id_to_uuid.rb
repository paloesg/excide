class ChangeDocumentIdToUuid < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :documents do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE documents ADD PRIMARY KEY (id);"
  end
end