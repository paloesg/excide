require "administrate/base_dashboard"

class CompanyDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    workflows: Field::HasMany,
    templates: Field::HasMany,
    documents: Field::HasMany,
    users: Field::HasMany,
    address: Field::HasOne,
    description: Field::Text,
    image_url: Field::Image,
    company_type: EnumField,
    ssic_code: Field::String,
    financial_year_end: Field::DateTime,
    xero_email: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    connect_xero: Field::Boolean,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :workflows,
    :templates,
    :documents,
    :users,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :company_type,
    :image_url,
    :description,
    :address,
    :users,
    :ssic_code,
    :financial_year_end,
    :xero_email,
    :connect_xero,
  ]

  # Overwrite this method to customize how profiles are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(company)
    "#{company.name}"
  end
end
