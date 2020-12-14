class AddCompanyRefToFranchisee < ActiveRecord::Migration[6.0]
  def change
    add_reference :franchisees, :company, type: :uuid, foreign_key: true
  end
end
