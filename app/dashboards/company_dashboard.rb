require "administrate/base_dashboard"

class CompanyDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String.with_options(searchable: false),
    name: Field::String,
    users: Field::HasMany,
    workflows: Field::HasMany,
    templates: Field::HasMany,
    documents: Field::HasMany,
    batches: Field::HasMany,
    invoices: Field::HasMany,
    address: Field::HasOne,
    description: Field::Text,
    image_url: Field::Image,
    company_type: EnumField,
    ssic_code: Field::String,
    financial_year_end: Field::DateTime,
    xero_email: Field::String,
    connect_xero: Field::Boolean,
    xero_organisation_name: Field::String,
    session_handle: Field::String,
    access_key: Field::String,
    access_secret: Field::String,
    expires_at: Field::Number,
    storage_limit: Field::Number,
    storage_used: Field::Number,
    account_type: EnumField,
    before_deadline_reminder_days: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    ancestry: Field::String,
    locked: Field::Boolean,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :users,
    :workflows,
    :templates,
    :documents,
    :ancestry,
    :locked,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :users,
    :company_type,
    :address,
    :description,
    :image_url,
    :ssic_code,
    :financial_year_end,
    :xero_email,
    :connect_xero,
    :xero_organisation_name,
    :session_handle,
    :access_key,
    :access_secret,
    :expires_at,
    :account_type,
    :before_deadline_reminder_days,
    :ancestry,
    :storage_limit,
    :storage_used,
    :locked,
  ]

  # Overwrite this method to customize how profiles are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(company)
    company.name
  end
end
