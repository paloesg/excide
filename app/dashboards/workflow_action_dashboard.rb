require "administrate/base_dashboard"

class WorkflowActionDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    task: Field::BelongsTo,
    company: Field::BelongsTo,
    workflow: Field::BelongsTo,
    deadline: Field::DateTime,
    reminders: Field::HasMany,
    assigned_user: Field::BelongsTo.with_options(class_name: 'User'),
    completed_user: Field::BelongsTo.with_options(class_name: 'User'),
    completed: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    time_spent_mins: Field::Number,
    remarks: Field::Text,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :company,
    :task,
    :workflow,
    :assigned_user,
    :deadline,
    :reminders,
    :completed,
    :completed_user,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :company,
    :task,
    :workflow,
    :assigned_user,
    :deadline,
    :reminders,
    :completed,
    :completed_user,
    :remarks,
    :time_spent_mins,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :company,
    :task,
    :workflow,
    :assigned_user,
    :deadline,
    :reminders,
    :completed,
    :completed_user,
    :remarks,
    :time_spent_mins,
  ].freeze

  # Overwrite this method to customize how actions are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(action)
  #   "Action ##{action.id}"
  # end
end
