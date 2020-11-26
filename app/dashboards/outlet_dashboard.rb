require "administrate/base_dashboard"

class OutletDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    franchisees: Field::HasMany,
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
    commencement_date: Field::Date,
    expiry_date: Field::Date,
    renewal_period_freq_unit: Field::Number,
    renewal_period_freq_value: Field::Number,
    report_url: Field::String,
    header_image: Field::ActiveStorage
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  name
  company
  commencement_date
  expiry_date
  report_url
  users
  notes
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  franchisees
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
  commencement_date
  expiry_date
  renewal_period_freq_unit
  renewal_period_freq_value
  report_url
  header_image
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  franchisees
  company
  documents
  users
  workflows
  notes
  city
  country
  name
  contact
  commencement_date
  expiry_date
  renewal_period_freq_unit
  renewal_period_freq_value
  report_url
  header_image
  address
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
