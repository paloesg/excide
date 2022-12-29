class AddDedocoLinksToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :dedoco_links, :json, default: '[]'
  end
end
