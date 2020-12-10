class RemoveColsFromOutlets < ActiveRecord::Migration[6.0]
  def change
    remove_column :outlets, :commencement_date, :date
    remove_column :outlets, :expiry_date, :date
    remove_column :outlets, :renewal_period_freq_unit, :integer
    remove_column :outlets, :renewal_period_freq_value, :integer
    remove_column :outlets, :franchise_licensee, :integer
    remove_column :outlets, :registered_address, :integer
  end
end
