class RenameActionIdColumns < ActiveRecord::Migration
  def change
    rename_column :reminders, :action_id, :company_action_id
  end
end
