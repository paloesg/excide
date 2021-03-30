class ChangeDefaultValueToStorage < ActiveRecord::Migration[6.1]
  def up
    change_column_default :companies, :storage_limit, 0
    change_column_default :companies, :storage_used, 0
  end

  def down
    change_column_default :companies, :storage_limit, nil
    change_column_default :companies, :storage_used, nil
  end
end
