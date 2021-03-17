require "administrate/base_dashboard"

class OutletsUserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    outlet: Field::BelongsTo,
    user: Field::BelongsTo,
    id: Field::String.with_options(searchable: false),
    name: Field::String,
    website_url: Field::String,
    established_date: Field::Date,
    contact: Field::String,
    annual_turnover_rate: Field::String.with_options(searchable: false),
    currency: Field::Number,
    description: Field::Text,
    contact_person_details: Field::String.with_options(searchable: false),
    company_id: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  outlet
  user
  id
  created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  outlet
  user
  id
  name
  website_url
  established_date
  contact
  annual_turnover_rate
  currency
  description
  contact_person_details
  company_id
  created_at
  updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  outlet
  user
  name
  website_url
  established_date
  contact
  annual_turnover_rate
  currency
  description
  contact_person_details
  company_id
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how outlets users are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(outlets_user)
  #   "OutletsUser ##{outlets_user.id}"
  # end
end