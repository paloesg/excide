class AddDefaultToAvailability < ActiveRecord::Migration
  def up
    change_column_default :availabilities, :assigned, false
  end

  def down
    change_column_default :availabilities, :assigned, nil
  end
end
