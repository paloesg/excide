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
    user: Field::BelongsTo,
    folder: Field::BelongsTo,
    child_workflow_template: Field::BelongsTo.with_options(class_name: "Template"),
    task_type: EnumField,
    instructions: Field::String,
    position: Field::Number,
    image_url: ImageField,
    link_url: Field::String,
    deadline_day: Field::Number,
    deadline_type: EnumField,
    set_reminder: Field::Boolean,
    important: Field::Boolean,
    document_template: Field::BelongsTo,
    survey_template: Field::BelongsTo,
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
    :user,
    :role,
    :set_reminder,
    :workflow_actions,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :instructions,
    :task_type,
    :section,
    :position,
    :user,
    :role,
    :folder,
    :document_template,
    :image_url,
    :link_url,
    :deadline_type,
    :deadline_day,
    :document_template,
    :survey_template,
    :child_workflow_template,
    :set_reminder,
    :important,
    :created_at,
    :updated_at,
    :workflow_actions,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :instructions,
    :task_type,
    :section,
    :position,
    :user,
    :role,
    :folder,
    :document_template,
    :image_url,
    :link_url,
    :deadline_type,
    :deadline_day,
    :document_template,
    :survey_template,
    :child_workflow_template,
    :set_reminder,
    :important,
    :workflow_actions,
  ].freeze

  # Overwrite this method to customize how tasks are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(task)
  #   "Task ##{task.id}"
  # end
end
