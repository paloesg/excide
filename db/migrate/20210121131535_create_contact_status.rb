class CreateContactStatus < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_statuses, id: :uuid do |t|
      t.belongs_to :startup, type: :uuid, foreign_key: { to_table: :companies }
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
