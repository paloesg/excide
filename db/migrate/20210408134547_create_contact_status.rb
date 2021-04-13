class CreateContactStatus < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_statuses, id: :uuid do |t|
      t.belongs_to :company, type: :uuid, foreign_key: true
      t.string :name
      t.integer :position
      t.timestamps
    end
  end
end
