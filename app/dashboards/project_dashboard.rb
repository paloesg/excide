require "administrate/base_dashboard"

class ProjectDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    business: Field::BelongsTo,
    id: Field::Number,
    title: Field::String,
    project_category: Field::BelongsTo,
    description: Field::Text,
    start_date: Field::DateTime,
    end_date: Field::DateTime,
    budget: Field::Number,
    budget_type: Field::String,
    remarks: Field::Text,
    criteria: Field::Text,
    grant: Field::String,
    status: Field::String,
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
    :title,
    :project_category,
    :status,
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :business,
    :title,
    :project_category,
    :description,
    :start_date,
    :end_date,
    :budget,
    :budget_type,
    :remarks,
    :criteria,
    :grant,
    :status,
  ]

  # Overwrite this method to customize how profiles are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(project)
    "#{project.title}"
  end
end
