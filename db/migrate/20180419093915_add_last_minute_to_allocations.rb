class AddLastMinuteToAllocations < ActiveRecord::Migration[5.2]
  def change
    add_column :allocations, :last_minute, :boolean
  end
end
