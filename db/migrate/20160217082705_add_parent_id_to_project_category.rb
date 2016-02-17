class AddParentIdToProjectCategory < ActiveRecord::Migration
  def change
    add_column :project_categories, :parent_id, :integer
  end
end
