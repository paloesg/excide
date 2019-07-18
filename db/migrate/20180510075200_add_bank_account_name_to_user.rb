class AddBankAccountNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :bank_account_name, :string
  end
end
