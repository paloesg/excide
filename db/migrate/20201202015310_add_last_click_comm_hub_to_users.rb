class AddLastClickCommHubToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_click_comm_hub, :datetime
  end
end
