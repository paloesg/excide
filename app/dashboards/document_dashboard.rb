require "administrate/base_dashboard"

class DocumentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String,
    company: Field::BelongsTo,
    workflow: Field::BelongsTo,
    document_template: Field::BelongsTo,
    user: Field::BelongsTo,
    remarks: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    filename: Field::String,
    file_url: Field::String,
    raw_file: Field::ActiveStorage,
    converted_images: Field::ActiveStorage,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :raw_file,
    :company,
    :user,
    :workflow,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :raw_file,
    :company,
    :user,
    :workflow,
    :document_template,
    :id,
    :remarks,
    :created_at,
    :updated_at,
    :converted_images,
    :filename,
    :file_url,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :raw_file,
    :company,
    :user,
    :workflow,
    :document_template,
    :remarks,
    :converted_images,
    :filename,
    :file_url,
  ].freeze

  # Overwrite this method to customize how documents are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(document)
  #   "Document ##{document.id}"
  # end
end
