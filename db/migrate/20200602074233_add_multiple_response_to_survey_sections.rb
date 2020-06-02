class AddMultipleResponseToSurveySections < ActiveRecord::Migration[6.0]
  def change
    add_column :survey_sections, :multiple_response, :boolean
  end
end
