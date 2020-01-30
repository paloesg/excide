class ChangeSurveyTemplatesPropertiesIdToUuid < ActiveRecord::Migration[6.0]
  def change
    # This migration file is to remove references, change questions, segments and survey_sections's ID to UUID and then add the necessary UUID references back
    remove_reference :questions, :survey_section, index: true, foreign_key: true
    remove_reference :responses, :segment, index: true, foreign_key: true
    remove_reference :segments, :survey_section, index: true, foreign_key: true

    add_column :survey_sections, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :survey_sections do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE survey_sections ADD PRIMARY KEY (id);"

    add_column :segments, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :segments do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE segments ADD PRIMARY KEY (id);"

    add_reference :questions, :survey_section, type: :uuid, null: false, index: true, foreign_key: true
    add_reference :responses, :segment, type: :uuid, null: false, index: true, foreign_key: true
    add_reference :segments, :survey_section, type: :uuid, null: false, index: true, foreign_key: true
  end
end
