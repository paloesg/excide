class RemoveAndAddCorrectForeignKeysForSurvey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :questions, :sections, column: "survey_section_id"
  	remove_foreign_key :surveys, :templates, column: "survey_template_id"
  	remove_foreign_key :segments, :sections, column: "survey_section_id"
  	add_foreign_key :questions, :survey_sections
  	add_foreign_key :surveys, :survey_templates
  	add_foreign_key :segments, :survey_sections
  end
end
