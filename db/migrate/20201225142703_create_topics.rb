class CreateTopics < ActiveRecord::Migration[6.0]
  def change
    create_table :topics, id: :uuid do |t|
      t.string :subject_name
      t.integer :status
      t.integer :question_category
      t.references :user, foreign_key: true
      t.references :company, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
