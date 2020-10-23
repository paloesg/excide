class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :company_name
      t.references :company, foreign_key: true
      t.references :created_by, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
