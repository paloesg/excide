class AddNameToOutlets < ActiveRecord::Migration[6.0]
  def change
    add_column :outlets, :name, :string
  end
end
