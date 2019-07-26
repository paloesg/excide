class AddTemplateToTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :template, foreign_key: true
  end
end
