class AddRateToAllocation < ActiveRecord::Migration
  def change
    add_column :allocations, :rate, :int
  end
end
