class RenamePriorDaysInCompanies < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :prior_day, :before_deadline_reminder_days
  end
end
