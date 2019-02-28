class AddWorkflowTypeToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :templates, :workflow_type, :integer, default: 0
  end
end