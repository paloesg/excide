class CreateExperiences < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.references :profile, index: true, foreign_key: true
      t.string :title
      t.string :company
      t.date :start_date
      t.date :end_date
      t.text :description

      t.timestamps null: false
    end
  end
end
