class ChangeDefaultStorageLimitForCompanies < ActiveRecord::Migration[6.1]
  def change
    change_column_default :companies, :storage_limit, from: 16106127360, to: 5368709120
  end
end
