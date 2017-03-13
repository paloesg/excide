require "administrate/base_dashboard"

class SegmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    section: Field::BelongsTo,
    survey: Field::BelongsTo,
    responses: Field::HasMany,
    id: Field::Number,
    name: Field::String,
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
    :id,
    :section,
    :survey,
    :responses,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :section,
    :survey,
    :responses,
    :id,
    :name,
    :position,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :section,
    :survey,
    :responses,
    :name,
    :position,
  ].freeze

  # Overwrite this method to customize how segments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(segment)
  #   "Segment ##{segment.id}"
  # end
end
