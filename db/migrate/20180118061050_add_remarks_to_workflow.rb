class AddRemarksToWorkflow < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :remarks, :text
  end
end
