class AddPriorDaysReminderToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :prior_days, :integer
  end
end
