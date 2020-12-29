class AddFranchiseeRefToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :franchisee, type: :uuid, foreign_key: true
  end
end
