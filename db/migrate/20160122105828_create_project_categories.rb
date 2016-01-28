class CreateProjectCategories < ActiveRecord::Migration
  def change
    create_table :project_categories do |t|
      t.string :name
      t.string :slug
      t.integer :status

      t.timestamps null: false
    end
  end
end
