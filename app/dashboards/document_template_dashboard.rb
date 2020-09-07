require "administrate/base_dashboard"

class DocumentTemplateDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    template: Field::BelongsTo,
    tasks: Field::HasMany,
    user: Field::BelongsTo,
    documents: Field::HasMany,
    id: Field::String,
    title: Field::String,
    description: Field::Text,
    file_url: Field::String,
    file: Field::ActiveStorage,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :file,
    :title,
    :template,
    :tasks,
    :documents,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :file,
    :title,
    :description,
    :template,
    :tasks,
    :user,
    :documents,
    :id,
    :created_at,
    :updated_at,
    :file_url,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :file,
    :title,
    :description,
    :template,
    :tasks,
    :user,
    :documents,
    :file_url,
  ].freeze

  # Overwrite this method to customize how document templates are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(document_template)
    document_template.title
  end
end
