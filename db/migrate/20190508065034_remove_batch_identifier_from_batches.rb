class RemoveBatchIdentifierFromBatches < ActiveRecord::Migration[5.2]
  def change
    remove_column :batches, :batch_identifier, :string
  end
end
