class ChangeRemarksToBeTextInWorkflowAction < ActiveRecord::Migration[5.2]
  def change
    change_column :workflow_actions, :remarks, :text
  end
end