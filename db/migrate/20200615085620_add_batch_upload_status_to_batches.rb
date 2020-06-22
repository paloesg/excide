class AddBatchUploadStatusToBatches < ActiveRecord::Migration[6.0]
  def change
    add_column :batches, :status, :integer
  end
end
