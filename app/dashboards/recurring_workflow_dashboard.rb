require "administrate/base_dashboard"

class RecurringWorkflowDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    template: Field::BelongsTo,
    workflows: Field::HasMany,
    id: Field::Number,
    freq_value: Field::Number,
    freq_unit: EnumField,
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
    :id,
    :template,
    :workflows,
    :freq_value,
    :freq_unit,
    :next_workflow_date,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :template,
    :workflows,
    :id,
    :freq_value,
    :freq_unit,
    :next_workflow_date,
    :created_at,
    :updated_at,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :template,
    :freq_value,
    :freq_unit,
    :next_workflow_date,
  ].freeze

  # Overwrite this method to customize how recurring workflows are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(recurring_workflow)
    "RecurringWorkflow ##{recurring_workflow.id}"
  end
end
