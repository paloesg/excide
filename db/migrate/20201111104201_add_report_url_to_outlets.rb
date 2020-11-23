class AddReportUrlToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_column :outlets, :report_url, :string
  end
end
