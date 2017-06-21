class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.references :user, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.references :template, index: true, foreign_key: true
      t.boolean :completed

      t.timestamps null: false
    end
  end
end
