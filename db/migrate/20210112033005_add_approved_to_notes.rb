class AddApprovedToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :approved, :boolean
  end
end
