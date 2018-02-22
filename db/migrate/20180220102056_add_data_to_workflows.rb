class AddDataToWorkflows < ActiveRecord::Migration
  def change
    add_column :workflows, :data, :json, default: '[]'
  end
end
