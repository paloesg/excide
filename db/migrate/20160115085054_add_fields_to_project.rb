class AddFieldsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :criteria, :text
    add_column :projects, :grant, :integer
  end
end
