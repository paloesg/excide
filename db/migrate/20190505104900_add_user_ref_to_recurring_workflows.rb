class AddUserRefToRecurringWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_reference :recurring_workflows, :user, foreign_key: true
  end
end
