require "administrate/base_dashboard"

class WorkflowDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    company: Field::BelongsTo,
    template: Field::BelongsTo,
    recurring_workflow: Field::BelongsTo,
    identifier: Field::String,
    id: Field::Number,
    completed: Field::Boolean,
    workflowable: Field::Polymorphic,
    workflow_actions: Field::HasMany,
    next_workflow_date: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :company,
    :identifier,
    :template,
    :workflowable,
    :recurring_workflow,
    :id,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :company,
    :identifier,
    :template,
    :workflowable,
    :workflow_actions,
    :id,
    :completed,
    :next_workflow_date,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :company,
    :identifier,
    :template,
    :recurring_workflow,
    :next_workflow_date,
    :completed,
  ].freeze

  # Overwrite this method to customize how workflows are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(workflow)
    workflow.identifier
  end
end
