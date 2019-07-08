class AddClientToActivation < ActiveRecord::Migration[5.2]
  def change
    add_reference :activations, :client, index: true, foreign_key: true
  end
end
