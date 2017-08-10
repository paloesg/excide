class AddDeadlineToWorkflow < ActiveRecord::Migration
  def change
    add_column :workflows, :deadline, :datetime
  end
end
