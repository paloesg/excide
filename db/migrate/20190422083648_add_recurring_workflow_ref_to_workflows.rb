class AddRecurringWorkflowRefToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_reference :workflows, :recurring_workflow, foreign_key: true
  end
end
