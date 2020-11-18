class AddTemplateTypeToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :template_type, :integer
  end
end
