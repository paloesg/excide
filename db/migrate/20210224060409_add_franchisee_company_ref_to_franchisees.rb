class AddFranchiseeCompanyRefToFranchisees < ActiveRecord::Migration[6.0]
  def change
    add_reference :franchisees, :franchisee_company, type: :uuid, foreign_key: {to_table: :companies}
  end
end
