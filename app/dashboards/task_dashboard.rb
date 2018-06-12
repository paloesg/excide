require "administrate/base_dashboard"

class TaskDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    section: Field::BelongsTo,
    workflow_actions: Field::HasMany,
    id: Field::Number,
    role: Field::BelongsTo,
    task_type: EnumField,
    instructions: Field::String,
    position: Field::Number,
    image_url: ImageField,
    link_url: Field::String,
    days_to_complete: Field::Number,
    set_reminder: Field::Boolean,
    document_template: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :task_type,
    :instructions,
    :section,
    :position,
    :role,
    :document_template,
    :days_to_complete,
    :set_reminder,
    :workflow_actions,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :task_type,
    :instructions,
    :section,
    :position,
    :role,
    :document_template,
    :image_url,
    :link_url,
    :days_to_complete,
    :set_reminder,
    :workflow_actions,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :task_type,
    :instructions,
    :section,
    :position,
    :role,
    :document_template,
    :image_url,
    :link_url,
    :days_to_complete,
    :set_reminder,
    :workflow_actions,
  ].freeze

  # Overwrite this method to customize how tasks are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(task)
  #   "Task ##{task.id}"
  # end
end
