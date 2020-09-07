class CreateFolders < ActiveRecord::Migration[6.0]
  def change
    create_table :folders, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
