class RemoveSlugFromProjectCategory < ActiveRecord::Migration
  def change
    remove_column :project_categories, :slug, :string
  end
end
