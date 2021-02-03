class CreateCategoryEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :categories_events, id: :uuid do |t|
      t.references :categories, type: :uuid, foreign_key: true
      t.references :events, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
