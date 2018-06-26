class RenameCompanyActionToWorkflowAction < ActiveRecord::Migration
  def change
    rename_table :company_actions, :workflow_actions
  end
end
