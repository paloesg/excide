class AddRemarksToFolders < ActiveRecord::Migration[6.0]
  def change
    add_column :folders, :remarks, :text
  end
end
