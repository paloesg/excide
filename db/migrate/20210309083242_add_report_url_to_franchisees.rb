class AddReportUrlToFranchisees < ActiveRecord::Migration[6.0]
  def change
    add_column :franchisees, :report_url, :string
  end
end
