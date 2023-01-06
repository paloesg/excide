class AddDedocoWebhookParamsToTasks < ActiveRecord::Migration[6.1]
  def change
    add_column :tasks, :dedoco_webhook_params, :json
  end
end
