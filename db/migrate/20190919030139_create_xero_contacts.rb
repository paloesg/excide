class CreateXeroContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :xero_contacts, id: :uuid do |t|
      t.string :name
      t.string :contact_id
      t.references :company, foreign_key: true
      t.timestamps
    end
  end
end
