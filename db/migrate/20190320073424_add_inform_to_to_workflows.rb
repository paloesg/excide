class AddInformToToWorkflows < ActiveRecord::Migration[5.2]
  def change
    add_column :workflows, :inform_to, :integer
    add_index :workflows, :inform_to
  end
end
