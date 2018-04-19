class AddLastMinuteToAllocations < ActiveRecord::Migration
  def change
    add_column :allocations, :last_minute, :boolean
  end
end
