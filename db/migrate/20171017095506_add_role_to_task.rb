class AddRoleToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :role, index: true, foreign_key: true
  end
end
