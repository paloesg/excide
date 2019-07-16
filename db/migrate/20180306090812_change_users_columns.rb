class ChangeUsersColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :allow_contact
    remove_column :users, :agree_terms
    add_column :users, :max_hours_per_week, :integer
  end
end
