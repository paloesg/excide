class DropQualifications < ActiveRecord::Migration[5.2]
  def change
    drop_table :qualifications
  end
end
