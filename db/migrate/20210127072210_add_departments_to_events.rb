class AddDepartmentsToEvents < ActiveRecord::Migration[6.0]
  def change
    add_reference :events, :department, type: :uuid, foreign_key: true
  end
end
