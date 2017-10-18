class AddApprovedByToCompanyActions < ActiveRecord::Migration
  def change
    add_column :company_actions, :approved_by, :integer
  end
end
