class AddFranchiseLicenseeAndRegisteredAddressToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_column :outlets, :franchise_licensee, :string
    add_column :outlets, :registered_address, :string
  end
end
