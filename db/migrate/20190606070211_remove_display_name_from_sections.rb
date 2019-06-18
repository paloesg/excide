class RemoveDisplayNameFromSections < ActiveRecord::Migration[5.2]
  def change
    remove_column :sections, :display_name, :string
  end
end
