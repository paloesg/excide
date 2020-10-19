class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes, id: :uuid do |t|
      t.string :notable_type
      t.uuid :notable_id
      t.text :content
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
