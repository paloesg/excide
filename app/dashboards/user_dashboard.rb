require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    first_name: Field::String,
    last_name: Field::String,
    email: Field::String,
    contact_number: Field::String,
    company: Field::BelongsTo,
    id: Field::Number,
    provider: Field::String,
    uid: Field::String,
    confirmed_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    reset_password_sent_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String.with_options(searchable: false),
    last_sign_in_ip: Field::String.with_options(searchable: false),
    roles: HasManyRolesField,
    assigned_tasks: Field::HasMany.with_options(class_name: WorkflowAction),
    completed_tasks: Field::HasMany.with_options(class_name: WorkflowAction),
    settings: Field::JSONB,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :first_name,
    :last_name,
    :email,
    :contact_number,
    :company,
    :roles,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :first_name,
    :last_name,
    :email,
    :contact_number,
    :company,
    :roles,
    :assigned_tasks,
    :completed_tasks,
    :settings,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :first_name,
    :last_name,
    :email,
    :contact_number,
    :company,
    :roles,
    :confirmed_at,
    :settings,
  ].freeze

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    "#{user.first_name} #{user.last_name}"
  end
end
