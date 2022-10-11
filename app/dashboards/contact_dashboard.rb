require "administrate/base_dashboard"

class ContactDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String,
    average_investment: Field::String,
    brand_logo: Field::ActiveStorage,
    company: Field::BelongsTo,
    company_name: Field::String,
    contact_status: Field::BelongsTo,
    country_of_origin: Field::String,
    created_by: Field::BelongsTo,
    description: Field::RichTextAreaField,
    email: Field::String,
    franchise_fees: Field::String,
    franchisor_tenure: Field::String,
    industry: Field::Select.with_options(searchable: false, collection: ->(field) { field.resource.class.send(field.attribute.to_s.pluralize).keys }),
    marketing_fees: Field::String,
    markets_available: Field::String,
    name: Field::String,
    notes: Field::HasMany,
    phone: Field::String,
    renewal_fees: Field::String,
    royalty: Field::String,
    searchable: Field::Boolean,
    year_founded: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    name
    created_by
    industry
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    average_investment
    brand_logo
    company
    company_name
    contact_status
    country_of_origin
    created_by
    email
    franchise_fees
    franchisor_tenure
    industry
    marketing_fees
    markets_available
    name
    notes
    phone
    renewal_fees
    description
    royalty
    searchable
    year_founded
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    average_investment
    brand_logo
    company
    company_name
    contact_status
    country_of_origin
    created_by
    email
    franchise_fees
    franchisor_tenure
    industry
    marketing_fees
    markets_available
    name
    notes
    phone
    renewal_fees
    description
    royalty
    searchable
    year_founded
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

  # Overwrite this method to customize how contacts are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(contact)
    "#{contact.name}"
  end
end
