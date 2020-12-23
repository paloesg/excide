class AddFranchiseeRefToFolders < ActiveRecord::Migration[6.0]
  def change
    add_reference :folders, :franchisee, type: :uuid, foreign_key: true
  end
end
