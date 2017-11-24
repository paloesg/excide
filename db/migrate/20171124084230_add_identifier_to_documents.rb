class AddIdentifierToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :identifier, :string
  end
end
