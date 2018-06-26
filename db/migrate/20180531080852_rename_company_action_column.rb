class RenameCompanyActionColumn < ActiveRecord::Migration
  def change
    rename_column :reminders, :company_action_id, :workflow_action_id
  end
end
