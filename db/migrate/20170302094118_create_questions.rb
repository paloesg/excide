class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :content
      t.integer :question_type
      t.integer :position
      t.references :section, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
