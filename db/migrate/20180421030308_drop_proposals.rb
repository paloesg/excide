class DropProposals < ActiveRecord::Migration[5.2]
  def change
    drop_table :proposals
  end
end
