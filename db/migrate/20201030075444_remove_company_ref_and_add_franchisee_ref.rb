class RemoveCompanyRefAndAddFranchiseeRef < ActiveRecord::Migration[6.0]
  def change
    remove_reference :outlets, :company
    add_reference :outlets, :franchisee, type: :uuid, foreign_key: true
  end
end
