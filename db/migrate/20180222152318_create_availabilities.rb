class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.references :user, index: true, foreign_key: true
      t.date :available_date
      t.time :start_time
      t.time :end_time
      t.boolean :assigned

      t.timestamps null: false
    end
  end
end
