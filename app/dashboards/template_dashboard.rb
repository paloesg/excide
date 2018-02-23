require "administrate/base_dashboard"

class TemplateDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    title: Field::String,
    slug: Field::String,
    business_model: EnumField,
    company: Field::BelongsTo,
    workflows: Field::HasMany,
    sections: Field::NestedHasMany.with_options(skip: [:template]),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    data_names: Field::JSON,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :title,
    :slug,
    :company,
    :workflows,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :slug,
    :company,
    :created_at,
    :updated_at,
    :sections,
    :workflows,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :title,
    :company,
    :data_names,
    :sections,
  ].freeze

  # Overwrite this method to customize how templates are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(template)
    template.title
  end
end
