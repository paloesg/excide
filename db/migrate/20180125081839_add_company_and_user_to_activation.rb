class AddCompanyAndUserToActivation < ActiveRecord::Migration[5.2]
  def change
    add_reference :activations, :company, index: true, foreign_key: true
    add_reference :activations, :user, index: true, foreign_key: true
  end
end
