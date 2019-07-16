class AddUserToCompanyAction < ActiveRecord::Migration[5.2]
  def change
    add_reference :company_actions, :user, index: true, foreign_key: true
  end
end
