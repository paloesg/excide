class CreateCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name
      t.integer :category_type
      t.references :department, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
