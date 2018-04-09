class CreateActivations < ActiveRecord::Migration
  def change
    create_table :activations do |t|
      t.integer :activation_type
      t.datetime :start_time
      t.datetime :end_time
      t.text :remarks
      t.string :location

      t.timestamps null: false
    end
  end
end
