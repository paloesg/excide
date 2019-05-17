class AddCompanyRefToRecurringWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_reference :recurring_workflows, :company, foreign_key: true
  end
end
