class AddCompanyRefToSurveyTemplates < ActiveRecord::Migration[6.0]
  def change
    add_reference :survey_templates, :company, foreign_key: true
  end
end
