class AddDataToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :data, :json, default: '[]'
  end
end
