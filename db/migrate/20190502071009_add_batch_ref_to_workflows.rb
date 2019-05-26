class AddBatchRefToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_reference :workflows, :batch, foreign_key: true
  end
end
