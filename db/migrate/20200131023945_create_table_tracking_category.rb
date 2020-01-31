class CreateTableTrackingCategory < ActiveRecord::Migration[6.0]
  def change
    create_table :tracking_categories, id: :uuid do |t|
      t.string :name
      t.string :status
      t.string :tracking_category_id
      t.json :options
    end
  end
end
