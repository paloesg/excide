class AddFolderRefToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :folder, type: :uuid, foreign_key: true
  end
end
