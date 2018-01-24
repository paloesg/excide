class CreateConductorActivations < ActiveRecord::Migration
  def change
    create_table :conductor_activations do |t|
      t.integer :activation_type
      t.datetime :start_time
      t.datetime :end_time
      t.text :remarks
      t.string :location

      t.timestamps null: false
    end
  end
end
