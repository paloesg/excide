require "administrate/base_dashboard"

class ProfileDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    experiences: Field::HasMany,
    qualifications: Field::HasMany,
    id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    headline: Field::String,
    summary: Field::Text,
    industry: Field::String,
    specialties: Field::String,
    image_url: Field::String,
    linkedin_url: Field::String,
    location: Field::String,
    country_code: Field::String,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :headline,
    :industry,
    :user,
    :experiences,
    :qualifications,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :experiences,
    :qualifications,
    :headline,
    :summary,
    :industry,
    :specialties,
    :image_url,
    :linkedin_url,
    :location,
    :country_code,
  ]

  # Overwrite this method to customize how profiles are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(profile)
  #   "Profile ##{profile.id}"
  # end
end
