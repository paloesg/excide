require "administrate/base_dashboard"

class ProposalDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    project: Field::BelongsTo,
    profile: Field::BelongsTo,
    id: Field::Number,
    qualifications: Field::Text,
    amount: Field::Number,
    file_url: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :profile,
    :qualifications,
    :amount,
    :project,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :project,
    :profile,
    :qualifications,
    :amount,
    :file_url,
  ]

  # Overwrite this method to customize how profiles are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(profile)
  #   "#{profile.user.first_name} #{profile.user.last_name}"
  # end
end
