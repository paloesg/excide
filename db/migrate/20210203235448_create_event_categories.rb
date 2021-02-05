class CreateEventCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :event_categories, id: :uuid do |t|
      t.references :category, type: :uuid, foreign_key: true
      t.references :event, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
