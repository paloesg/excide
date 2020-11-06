class CreateProfile < ActiveRecord::Migration[6.0]
  def change
    create_table :profiles, id: :uuid do |t|
      t.string :name
      t.string :url
    end
  end
end
