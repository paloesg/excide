class AddFranchiseeRefToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :franchisee, type: :uuid, foreign_key: true
  end
end
