class RenameTypeToCompanyType < ActiveRecord::Migration
  def change
    rename_column :businesses, :type, :company_type
  end
end
