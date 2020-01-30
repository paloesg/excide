class AddSlugToWorkflows < ActiveRecord::Migration[6.0]
  def change
    add_column :workflows, :slug, :string
    add_index :workflows, :slug, unique: true
  end
end
