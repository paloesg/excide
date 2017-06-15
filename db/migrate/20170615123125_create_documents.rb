class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :filename
      t.string :file_type
      t.references :company, index: true, foreign_key: true
      t.date :date_signed
      t.date :date_uploaded

      t.timestamps null: false
    end
  end
end
