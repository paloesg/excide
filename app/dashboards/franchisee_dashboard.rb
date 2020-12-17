require "administrate/base_dashboard"

class FranchiseeDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    company: Field::BelongsTo,
    outlets: Field::HasMany,
    id: Field::String.with_options(searchable: false),
    franchise_licensee: Field::String,
    registered_address: Field::String,
    commencement_date: Field::Date,
    expiry_date: Field::Date,
    renewal_period_freq_unit: EnumField,
    renewal_period_freq_value: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  id
  franchise_licensee
  registered_address
  company
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  id
  company
  franchise_licensee
  registered_address
  commencement_date
  expiry_date
  renewal_period_freq_unit
  renewal_period_freq_value
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  company
  franchise_licensee
  registered_address
  commencement_date
  expiry_date
  renewal_period_freq_unit
  renewal_period_freq_value
  outlets
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

  # Overwrite this method to customize how franchisees are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(franchisee)
    "#{franchisee.franchise_licensee} - #{franchisee.company.name}"
  end
end
