class CreateProfileFields < ActiveRecord::Migration[6.1]
  def change
    create_table :profile_fields, id: :uuid do |t|
      t.string :field

      t.timestamps
    end
  end
end
