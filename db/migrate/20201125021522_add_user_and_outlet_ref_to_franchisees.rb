class AddUserAndOutletRefToFranchisees < ActiveRecord::Migration[6.0]
  def change
    # Franchisee to add reference because it is a join table
    add_reference :franchisees, :user, foreign_key: true
    add_reference :franchisees, :outlet, type: :uuid, foreign_key: true
    # Remove franchisee ref from outlet
    remove_reference :outlets, :franchisee, type: :uuid, foreign_key: true
    # Remove outlet & franchisee reference from user
    remove_reference :users, :franchisee, type: :uuid, foreign_key: true
  end
end
