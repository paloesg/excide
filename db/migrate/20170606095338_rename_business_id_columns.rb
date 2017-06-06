class RenameBusinessIdColumns < ActiveRecord::Migration
  def change
    rename_column :projects, :business_id, :company_id
    rename_column :reminders, :business_id, :company_id
    rename_column :surveys, :business_id, :company_id
  end
end
