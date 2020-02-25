class AddSurveyTemplateRefToTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :tasks, :survey_template, foreign_key: true
  end
end
