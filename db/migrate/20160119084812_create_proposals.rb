class CreateProposals < ActiveRecord::Migration
  def change
    create_table :proposals do |t|
      t.references :profile, index: true, foreign_key: true
      t.text :qualifications
      t.integer :amount

      t.timestamps null: false
    end
  end
end
