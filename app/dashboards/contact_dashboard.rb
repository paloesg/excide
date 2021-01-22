require "administrate/base_dashboard"

class ContactDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    company: Field::BelongsTo,
    created_by: Field::BelongsTo.with_options(class_name: "User"),
    contact_status: Field::BelongsTo,
    investor_information: RichTextAreaField,
    notes: Field::HasMany,
    id: Field::String.with_options(searchable: false),
    name: Field::String,
    phone: Field::String,
    email: Field::String,
    company_name: Field::String,
    created_by_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    public: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
  company
  created_by
  contact_status
  investor_information
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
  company
  created_by
  contact_status
  investor_information
  notes
  id
  name
  phone
  email
  company_name
  created_by_id
  created_at
  updated_at
  public
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
  company
  created_by
  contact_status
  investor_information
  notes
  name
  phone
  email
  company_name
  created_by_id
  public
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
  # def display_resource(contact)
  #   "Contact ##{contact.id}"
  # end
end
