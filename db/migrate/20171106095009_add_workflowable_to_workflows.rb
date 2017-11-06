class AddWorkflowableToWorkflows < ActiveRecord::Migration
  def change
    add_reference :workflows, :workflowable, polymorphic: true, index: true
  end
end
