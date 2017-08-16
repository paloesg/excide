class CreateSurveyTemplates < ActiveRecord::Migration
  def change
    create_table :survey_templates do |t|
      t.string :title
      t.string :slug

      t.timestamps null: false
    end
  end
end
