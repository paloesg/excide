class AddUserToDocument < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :user, index: true, foreign_key: true
  end
end
