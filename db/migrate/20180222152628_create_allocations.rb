class CreateAllocations < ActiveRecord::Migration[5.2]
  def change
    create_table :allocations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :activation, index: true, foreign_key: true
      t.date :allocation_date
      t.time :start_time
      t.time :end_time

      t.timestamps null: false
    end
  end
end
