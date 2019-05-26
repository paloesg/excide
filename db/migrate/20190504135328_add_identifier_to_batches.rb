class AddIdentifierToBatches < ActiveRecord::Migration[5.2]
  def change
    add_column :batches, :batch_identifier, :string
  end
end
