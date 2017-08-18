class CreateSurveySections < ActiveRecord::Migration
  def change
    create_table :survey_sections do |t|
      t.string :unique_name
      t.string :display_name
      t.integer :position
      t.references :survey_template, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
