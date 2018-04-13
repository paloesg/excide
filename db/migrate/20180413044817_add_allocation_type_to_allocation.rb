class AddAllocationTypeToAllocation < ActiveRecord::Migration
  def change
    add_column :allocations, :allocation_type, :integer
  end
end
