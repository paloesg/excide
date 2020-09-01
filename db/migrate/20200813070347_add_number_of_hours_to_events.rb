class AddNumberOfHoursToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :number_of_hours, :decimal
  end
end
