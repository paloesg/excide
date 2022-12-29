class AddTaskRefToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_reference :documents, :task, foreign_key: true
  end
end
