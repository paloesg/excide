require "administrate/base_dashboard"

class EnquiryDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    contact: Field::String,
    email: Field::String,
    comments: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    source: Field::String,
    responded: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :contact,
    :email,
    :source,
    :responded,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :contact,
    :email,
    :comments,
    :created_at,
    :updated_at,
    :source,
    :responded,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :contact,
    :email,
    :comments,
    :source,
    :responded,
  ].freeze

  # Overwrite this method to customize how enquiries are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(enquiry)
  #   "Enquiry ##{enquiry.id}"
  # end
end
