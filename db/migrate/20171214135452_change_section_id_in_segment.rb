class ChangeSectionIdInSegment < ActiveRecord::Migration
  def change
    rename_column :segments, :section_id, :survey_section_id
  end
end
