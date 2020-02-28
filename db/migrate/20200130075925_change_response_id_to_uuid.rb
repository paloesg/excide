class ChangeResponseIdToUuid < ActiveRecord::Migration[6.0]
  def change
    add_column :responses, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :responses do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE responses ADD PRIMARY KEY (id);"
  end
end
