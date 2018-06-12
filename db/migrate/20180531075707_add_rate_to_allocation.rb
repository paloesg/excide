class AddRateToAllocation < ActiveRecord::Migration
  def change
    add_column :allocations, :rate_cents, :int
  end
end
