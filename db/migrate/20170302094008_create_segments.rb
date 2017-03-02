class CreateSegments < ActiveRecord::Migration
  def change
    create_table :segments do |t|
      t.string :name
      t.integer :position
      t.references :section, index: true, foreign_key: true
      t.references :survey, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
