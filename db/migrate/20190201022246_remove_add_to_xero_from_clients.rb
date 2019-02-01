class RemoveAddToXeroFromClients < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :add_to_xero, :boolean
  end
end