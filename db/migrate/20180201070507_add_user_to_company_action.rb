class AddUserToCompanyAction < ActiveRecord::Migration
  def change
    add_reference :company_actions, :user, index: true, foreign_key: true
  end
end
