class RenameTemplateIdToSurveyTemplateId < ActiveRecord::Migration
  def change
    rename_column :surveys, :template_id, :survey_template_id
  end
end
