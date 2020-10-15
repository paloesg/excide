class CreateOutlets < ActiveRecord::Migration[6.0]
  def change
    create_table :outlets, id: :uuid do |t|
      t.string :city
      t.string :country
      t.timestamps
    end
  end
end
