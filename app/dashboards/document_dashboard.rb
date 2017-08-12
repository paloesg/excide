require "administrate/base_dashboard"

class DocumentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    company: Field::BelongsTo,
    id: Field::Number,
    filename: Field::String,
    remarks: Field::Text,
    date_signed: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    file_url: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :company,
    :id,
    :filename,
    :remarks,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :company,
    :id,
    :filename,
    :remarks,
    :date_signed,
    :created_at,
    :updated_at,
    :file_url,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :company,
    :filename,
    :remarks,
    :date_signed,
    :file_url,
  ].freeze

  # Overwrite this method to customize how documents are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(document)
  #   "Document ##{document.id}"
  # end
end
