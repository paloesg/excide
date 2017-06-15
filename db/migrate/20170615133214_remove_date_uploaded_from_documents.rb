class RemoveDateUploadedFromDocuments < ActiveRecord::Migration
  def change
    remove_column :documents, :date_uploaded, :date
  end
end
