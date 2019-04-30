class RemoveRecurringFromRecurringWorkflow < ActiveRecord::Migration[5.2]
  def change
    remove_column :recurring_workflows, :recurring, :boolean
  end
end
