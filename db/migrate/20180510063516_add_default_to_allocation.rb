class AddDefaultToAllocation < ActiveRecord::Migration[5.2]
  def up
    change_column_default :allocations, :last_minute, false
  end

  def down
    change_column_default :allocations, :last_minute, nil
  end
end
