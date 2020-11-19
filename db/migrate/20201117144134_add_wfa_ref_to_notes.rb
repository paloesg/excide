class AddWfaRefToNotes < ActiveRecord::Migration[6.0]
  def change
    add_reference :notes, :workflow_action, foreign_key: true
  end
end
