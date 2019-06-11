class AddBatchesUuidRefToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_reference :workflows, :batch, type: :uuid, foreign_key: true
  end
end
