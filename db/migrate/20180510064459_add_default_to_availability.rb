class AddDefaultToAvailability < ActiveRecord::Migration[5.2]
  def up
    change_column_default :availabilities, :assigned, false
  end

  def down
    change_column_default :availabilities, :assigned, nil
  end
end
