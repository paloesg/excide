class AddSurveyTypeToSurveyTemplate < ActiveRecord::Migration
  def change
    add_column :survey_templates, :survey_type, :integer
  end
end
