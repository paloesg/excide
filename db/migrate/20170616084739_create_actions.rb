class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.references :task, index: true, foreign_key: true
      t.boolean :completed

      t.timestamps null: false
    end
  end
end
