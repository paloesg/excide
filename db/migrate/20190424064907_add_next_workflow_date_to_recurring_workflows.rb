class AddNextWorkflowDateToRecurringWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :recurring_workflows, :next_workflow_date, :date
  end
end
