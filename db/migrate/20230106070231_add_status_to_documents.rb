class AddStatusToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :status, :integer
  end
end
