class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.string :title
      t.text :content
      t.references :company, type: :uuid, foreign_key: true
      t.references :author, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
