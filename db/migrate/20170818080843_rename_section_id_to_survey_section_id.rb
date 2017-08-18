class RenameSectionIdToSurveySectionId < ActiveRecord::Migration
  def change
    rename_column :questions, :section_id, :survey_section_id
  end
end
