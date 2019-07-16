class AddRateToAllocation < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations, :rate_cents, :int
  end
end
