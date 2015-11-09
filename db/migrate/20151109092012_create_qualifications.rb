class CreateQualifications < ActiveRecord::Migration
  def change
    create_table :qualifications do |t|
      t.references :profile, index: true, foreign_key: true
      t.string :institution
      t.string :title
      t.integer :year_obtained
      t.text :description

      t.timestamps null: false
    end
  end
end
