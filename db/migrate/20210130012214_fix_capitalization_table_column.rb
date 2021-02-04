class FixCapitalizationTableColumn < ActiveRecord::Migration[6.0]
  def change
    rename_column :companies, :capitalization_table_url, :cap_table_url
  end
end
