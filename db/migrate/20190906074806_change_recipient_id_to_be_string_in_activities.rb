class ChangeRecipientIdToBeStringInActivities < ActiveRecord::Migration[5.2]
  def change
    change_column :activities, :recipient_id, :string
  end
end
