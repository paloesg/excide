class AddSettingsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :settings, :json, default: [{reminder_sms: '', reminder_email: 'true', reminder_slack: '', task_sms: '', task_email: 'true', task_slack: '', batch_sms: '', batch_email: 'true', batch_slack: '' }]
  end
end
