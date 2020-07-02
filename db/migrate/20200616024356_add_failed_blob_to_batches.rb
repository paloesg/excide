class AddFailedBlobToBatches < ActiveRecord::Migration[6.0]
  def change
    add_column :batches, :failed_blob, :json, default: { blobs: []}
  end
end
