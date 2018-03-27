class RenameUserInCompanyAction < ActiveRecord::Migration
  def change
    rename_column :company_actions, :user_id, :assigned_user_id
    add_column :company_actions, :completed_user_id, :integer
    add_index :company_actions, :completed_user_id
    add_foreign_key :company_actions, :users, column: :completed_user_id
  end
end
