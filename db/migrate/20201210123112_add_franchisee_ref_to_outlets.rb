class AddFranchiseeRefToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_reference :outlets, :franchisee, type: :uuid, foreign_key: true
  end
end
