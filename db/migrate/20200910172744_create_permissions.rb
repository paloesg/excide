class CreatePermissions < ActiveRecord::Migration[6.0]
  def change
    create_table :permissions, id: :uuid do |t|
      t.references :folder, foreign_key: true, type: :uuid
      t.references :role, foreign_key: true
      t.boolean :can_write
      t.boolean :can_view
      t.boolean :can_download

      t.timestamps
    end
  end
end
