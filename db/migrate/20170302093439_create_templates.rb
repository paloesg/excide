class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :title
      t.integer :business_model

      t.timestamps null: false
    end
  end
end
