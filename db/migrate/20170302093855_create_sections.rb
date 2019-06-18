class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :section_name
      t.string :display_name
      t.integer :position
      t.references :template, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
