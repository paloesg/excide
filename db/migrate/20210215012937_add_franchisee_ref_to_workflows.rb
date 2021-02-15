class AddFranchiseeRefToWorkflows < ActiveRecord::Migration[6.0]
  def change
    add_reference :workflows, :franchisee, type: :uuid, foreign_key: true
  end
end
