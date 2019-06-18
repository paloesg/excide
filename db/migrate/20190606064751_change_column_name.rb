class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :sections, :unique_name, :section_name
  end
end
