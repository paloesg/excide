class RenameFileTypeToRemarksInDocuments < ActiveRecord::Migration
  def change
    rename_column :documents, :file_type, :remarks
    change_column :documents, :remarks, :text
  end
end
