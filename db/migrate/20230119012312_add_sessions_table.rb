class AddSessionsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.string :document_hash, :null => true
      t.jsonb :data
      t.timestamps
    end

    add_index :sessions, :updated_at
  end
end
