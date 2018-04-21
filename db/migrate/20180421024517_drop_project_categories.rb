class DropProjectCategories < ActiveRecord::Migration
  def change
    drop_table :project_categories
  end
end
