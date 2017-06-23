class AddDeadlineToAction < ActiveRecord::Migration
  def change
    add_column :actions, :deadline, :datetime
  end
end
