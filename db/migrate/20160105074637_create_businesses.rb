class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :industry
      t.integer :type

      t.timestamps null: false
    end
  end
end
