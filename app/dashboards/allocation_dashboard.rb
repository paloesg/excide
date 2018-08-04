require "administrate/base_dashboard"

class AllocationDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    activation: Field::BelongsTo,
    id: Field::Number,
    allocation_date: Field::DateTime,
    start_time: Field::Time,
    end_time: Field::Time,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    allocation_type: Field::String.with_options(searchable: false),
    last_minute: Field::Boolean,
    rate_cents: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :activation,
    :id,
    :allocation_date,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :activation,
    :id,
    :allocation_date,
    :start_time,
    :end_time,
    :created_at,
    :updated_at,
    :allocation_type,
    :last_minute,
    :rate_cents,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :activation,
    :allocation_date,
    :start_time,
    :end_time,
    :allocation_type,
    :last_minute,
    :rate_cents,
  ].freeze

  # Overwrite this method to customize how allocations are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(allocation)
  #   "Allocation ##{allocation.id}"
  # end
end
