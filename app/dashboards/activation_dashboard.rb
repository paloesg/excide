require "administrate/base_dashboard"

class EventDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    staffer: Field::BelongsTo.with_options(class_name: "User"),
    company: Field::BelongsTo,
    client: Field::BelongsTo,
    event_type: Field::BelongsTo,
    address: Field::HasOne,
    allocations: Field::HasMany,
    id: Field::Number,
    start_time: Field::DateTime,
    end_time: Field::DateTime,
    remarks: Field::Text,
    location: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :staffer,
    :company,
    :client,
    :event_type,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :staffer,
    :company,
    :client,
    :event_type,
    :address,
    :allocations,
    :id,
    :start_time,
    :end_time,
    :remarks,
    :location,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :staffer,
    :company,
    :client,
    :event_type,
    :address,
    :allocations,
    :start_time,
    :end_time,
    :remarks,
    :location,
  ].freeze

  # Overwrite this method to customize how events are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(event)
  #   "Event ##{event.id}"
  # end
end