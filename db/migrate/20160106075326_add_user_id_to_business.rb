class AddUserIdToBusiness < ActiveRecord::Migration
  def change
    add_reference :businesses, :user, index: true, foreign_key: true
  end
end
