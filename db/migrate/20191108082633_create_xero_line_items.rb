class CreateXeroLineItems < ActiveRecord::Migration[5.2]
  def change
    create_table :xero_line_items do |t|
      t.string :item_code
      t.string :description
      t.integer :quantity
      t.decimal :price
      t.string :account
      t.string :tax
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
