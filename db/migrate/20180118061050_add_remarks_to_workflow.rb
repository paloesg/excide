class AddRemarksToWorkflow < ActiveRecord::Migration
  def change
    add_column :workflows, :remarks, :text
  end
end
