class RenameCompanyActionToWorkflowAction < ActiveRecord::Migration[5.2]
  def change
    rename_table :company_actions, :workflow_actions
  end
end
