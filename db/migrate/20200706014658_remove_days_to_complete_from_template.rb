class RemoveDaysToCompleteFromTemplate < ActiveRecord::Migration[6.0]
  def change
    remove_column :templates, :days_to_complete, :integer
  end
end
