class AddPostRefToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_reference :documents, :post, foreign_key: true, type: :uuid
  end
end
