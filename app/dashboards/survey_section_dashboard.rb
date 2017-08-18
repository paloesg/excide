require "administrate/base_dashboard"

class SurveySectionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    survey_template: Field::BelongsTo,
    questions: Field::HasMany.with_options(limit: 50),
    segments: Field::HasMany,
    id: Field::Number,
    unique_name: Field::String,
    display_name: Field::String,
    position: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :survey_template,
    :id,
    :unique_name,
    :display_name,
    :questions,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :survey_template,
    :questions,
    :id,
    :unique_name,
    :display_name,
    :position,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :survey_template,
    :unique_name,
    :display_name,
    :position,
    :questions,
  ].freeze

  # Overwrite this method to customize how survey sections are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(survey_section)
    survey_section.unique_name
  end
end
