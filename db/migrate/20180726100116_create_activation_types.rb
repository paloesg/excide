class CreateActivationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :activation_types do |t|
      t.string :name
      t.string :slug
      t.string :colour

      t.timestamps null: false
    end
  end
end
