class AddRecurringAttributesToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :template_pattern, :integer
    add_column :templates, :freq_value, :integer
    add_column :templates, :freq_unit, :integer
    add_column :templates, :next_workflow_date, :date
    add_column :templates, :start_date, :date
    add_column :templates, :end_date, :date
  end
end
