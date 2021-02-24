class RenameCompanyIdToParentCompanyId < ActiveRecord::Migration[6.0]
  def change
     rename_column :franchisees, :company_id, :parent_company_id
  end
end
