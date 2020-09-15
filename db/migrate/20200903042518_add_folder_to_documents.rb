class AddFolderToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :folder, type: :uuid, foreign_key: true
  end
end
