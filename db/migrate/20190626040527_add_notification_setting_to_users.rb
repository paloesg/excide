class AddNotificationSettingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_settings, :json, default: []
  end
end
