class AddFileUrlToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :file_url, :string
  end
end
