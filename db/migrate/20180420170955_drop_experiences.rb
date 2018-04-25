class DropExperiences < ActiveRecord::Migration
  def change
    drop_table :experiences
  end
end
