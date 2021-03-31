class AddUserLimitToOutlets < ActiveRecord::Migration[6.1]
  def change
    add_column :outlets, :user_limit, :integer
  end
end
