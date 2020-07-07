class AddDeadlineToTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :templates, :deadline_day, :integer
    add_column :templates, :deadline_type, :integer
    add_column :templates, :days_to_complete, :integer
  end
end
