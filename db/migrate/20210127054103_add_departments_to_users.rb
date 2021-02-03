class AddDepartmentsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :department, type: :uuid, foreign_key: true
  end
end
