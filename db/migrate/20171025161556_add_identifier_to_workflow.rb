class AddIdentifierToWorkflow < ActiveRecord::Migration
  def change
    add_column :workflows, :identifier, :string
  end
end
