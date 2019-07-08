class AddAllocationTypeToAllocation < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations, :allocation_type, :integer
  end
end
