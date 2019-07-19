class DropExperiences < ActiveRecord::Migration[5.2]
  def change
    drop_table :experiences
  end
end
