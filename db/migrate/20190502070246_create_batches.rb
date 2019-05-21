class CreateBatches < ActiveRecord::Migration[5.2]
  def change
    create_table :batches do |t|
      t.references :company, foreign_key: true
      t.references :template, foreign_key: true

      t.timestamps
    end
  end
end
