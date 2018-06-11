class AddArchiveToWorkflow < ActiveRecord::Migration
  def change
    add_column :workflows, :archive, :json, default: '[]'
  end
end
