class AddSlugToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :slug, :string
    add_index :templates, :slug, unique: true
  end
end
