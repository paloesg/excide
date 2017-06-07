class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :line_1
      t.string :line_2
      t.string :postal_code
      t.references :addressable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
