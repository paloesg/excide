class ChangeProjectCategory < ActiveRecord::Migration
  def change
    rename_column :projects, :category, :project_category_id
  end
end
