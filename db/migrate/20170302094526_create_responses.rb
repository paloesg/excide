class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.text :content
      t.references :question, index: true, foreign_key: true
      t.references :choice, index: true, foreign_key: true
      t.references :segment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
