class AddFieldsToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :uen, :string
    add_column :companies, :contact_details, :text
    add_column :companies, :agm_date, :date
    add_column :companies, :ar_date, :date
    add_column :companies, :eci_date, :date
    add_column :companies, :form_cs_date, :date
    add_column :companies, :gst_quarter, :integer
    add_column :companies, :project_start_date, :date
    add_reference :companies, :consultant, foreign_key: { to_table: :users }
    add_reference :companies, :associate, foreign_key: { to_table: :users }
    add_reference :companies, :shared_service, foreign_key: { to_table: :users }
    add_column :companies, :designated_working_time, :string
  end
end
