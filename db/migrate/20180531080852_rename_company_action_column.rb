class RenameCompanyActionColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :reminders, :company_action_id, :workflow_action_id
  end
end
