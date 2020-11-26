class AddUserRefToPermissions < ActiveRecord::Migration[6.0]
  def change
    add_reference :permissions, :user, foreign_key: true
  end
end
