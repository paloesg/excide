class ChangeRateToDecimalInAllocation < ActiveRecord::Migration
  def change
  	change_column :allocations, :rate, :money
  end
end
