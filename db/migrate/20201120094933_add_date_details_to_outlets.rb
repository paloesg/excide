class AddDateDetailsToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_column :outlets, :commencement_date, :date
    add_column :outlets, :expiry_date, :date
    add_column :outlets, :renewal_period_freq_unit, :integer
    add_column :outlets, :renewal_period_freq_value, :integer
  end
end
