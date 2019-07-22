class DropProjectCategories < ActiveRecord::Migration[5.2]
  def change
    drop_table :project_categories
  end
end
