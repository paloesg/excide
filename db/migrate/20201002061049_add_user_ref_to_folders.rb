class AddUserRefToFolders < ActiveRecord::Migration[6.0]
  def change
    add_reference :folders, :user, foreign_key: true
  end
end
