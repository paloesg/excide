class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.integer :category
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :budget
      t.integer :budget_type
      t.text :remarks
      t.integer :status

      t.timestamps null: false
    end
  end
end
