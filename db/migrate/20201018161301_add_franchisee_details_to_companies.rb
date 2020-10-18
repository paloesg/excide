class AddFranchiseeDetailsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :franchisee_details, :json
  end
end
