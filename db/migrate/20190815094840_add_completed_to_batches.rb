class AddCompletedToBatches < ActiveRecord::Migration[5.2]
  def change
    add_column :batches, :completed, :boolean
  end
end
