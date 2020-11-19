class AddOutletRefToWorkflows < ActiveRecord::Migration[6.0]
  def change
    add_reference :workflows, :outlet, type: :uuid, foreign_key: true
  end
end
