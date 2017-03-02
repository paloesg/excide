class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :title
      t.text :remarks
      t.references :user, index: true, foreign_key: true
      t.references :business, index: true, foreign_key: true
      t.references :template, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
