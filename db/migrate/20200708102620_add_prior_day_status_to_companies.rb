class AddPriorDayStatusToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :prior_day_status, :integer
  end
end
