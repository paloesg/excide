class AddRegisterInterestDataToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :register_interest_data, :jsonb, default: []
  end
end
