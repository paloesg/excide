class AddDedocoTokenToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :dedoco_token, :string
  end
end
