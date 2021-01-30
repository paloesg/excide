class CreateDepartments < ActiveRecord::Migration[6.0]
  def change
    create_table :departments, id: :uuid do |t|
      t.string :name
      t.references :company, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
