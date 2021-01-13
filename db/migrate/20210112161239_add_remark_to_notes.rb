class AddRemarkToNotes < ActiveRecord::Migration[6.0]
  def change
    add_column :notes, :remark, :string
  end
end
