class AddAvailabilityToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_reference :allocations, :availability, foreign_key: true
  end
end
