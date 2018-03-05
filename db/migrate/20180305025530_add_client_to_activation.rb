class AddClientToActivation < ActiveRecord::Migration
  def change
    add_reference :activations, :client, index: true, foreign_key: true
  end
end
