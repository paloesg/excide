class AddFranchiseeRefToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_reference :companies, :franchise, index: true
  end
end
