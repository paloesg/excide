class RemoveBatchRefFromWorkflows < ActiveRecord::Migration[5.2]
  def change
    remove_reference :workflows, :batch, foreign_key: true
  end
end
