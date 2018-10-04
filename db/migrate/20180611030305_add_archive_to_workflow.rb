class AddArchiveToWorkflow < ActiveRecord::Migration[4.2]
  def change
    add_column :workflows, :archive, :json, default: '[]'
  end
end
