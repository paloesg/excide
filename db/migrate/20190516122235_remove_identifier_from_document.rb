class RemoveIdentifierFromDocument < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :identifier, :string
  end
end
