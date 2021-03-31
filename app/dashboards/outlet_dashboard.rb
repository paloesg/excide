require "administrate/base_dashboard"

class OutletDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    franchisee: Field::BelongsTo,
    company: Field::BelongsTo,
    address: Field::HasOne,
    documents: Field::HasMany,
    users: Field::HasMany,
    workflows: Field::HasMany,
    notes: Field::HasMany,
    id: Field::String.with_options(searchable: false),
    city: Field::String,
    country: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    name: Field::String,
    contact: Field::String,
    report_url: Field::String,
    header_image: Field::ActiveStorage,
    user_limit: Field::Number
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  name
  company
  report_url
  users
  notes
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  franchisee
  company
  address
  documents
  users
  workflows
  notes
  id
  city
  country
  created_at
  updated_at
  name
  contact
  report_url
  header_image
  user_limit
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  franchisee
  company
  documents
  users
  workflows
  notes
  city
  country
  name
  contact
  report_url
  header_image
  address
  user_limit
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

  # Overwrite this method to customize how outlets are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(outlet)
    "[#{outlet.company.name}] #{outlet.name}"
  end
end
