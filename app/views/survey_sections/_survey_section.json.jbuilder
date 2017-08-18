json.extract! survey_section, :id, :unique_name, :display_name, :position, :survey_template_id, :created_at, :updated_at
json.url survey_section_url(survey_section, format: :json)
