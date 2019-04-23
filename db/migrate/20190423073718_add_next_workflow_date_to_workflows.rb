class AddNextWorkflowDateToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :next_workflow_date, :date
  end
end
