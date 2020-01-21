class RenameColumnTemplateId < ActiveRecord::Migration[6.0]
  def change
    rename_column :tasks, :template_id, :child_workflow_template_id
  end
end
