class AddDescriptionToSurveySections < ActiveRecord::Migration[6.0]
  def change
    add_column :survey_sections, :description, :text
  end
end
