class AddDedocoCompleteSigningLinkToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :dedoco_complete_signing_link, :string
  end
end
