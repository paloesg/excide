class RenameActionsToCompanyActions < ActiveRecord::Migration
  def change
    rename_table :actions, :company_actions
  end
end
