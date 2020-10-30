class CreateFranchisees < ActiveRecord::Migration[6.0]
  def change
    create_table :franchisees, id: :uuid do |t|
      t.string :name
      t.string :website
      t.date :established_date
      t.string :telephone
      t.decimal :annual_turnover_rate
      t.integer :currency
      t.string :address
      t.text :description
      t.json :contact_person_details
      t.references :company, type: :uuid

      t.timestamps
    end
  end
end
