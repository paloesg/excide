require "administrate/base_dashboard"

class BatchDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    company: Field::BelongsTo,
    template: Field::BelongsTo,
    workflows: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    id: Field::String.with_options(searchable: false),
    name: Field::String,
    completed: Field::Boolean,
    workflow_progress: Field::Number,
    task_progress: Field::Number,
    status: EnumField,
    failed_blob: Field::JSONB,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :name,
    :company,
    :template,
    :workflows,
    :workflow_progress,
    :task_progress,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :name,
    :id,
    :company,
    :template,
    :status,
    :completed,
    :workflow_progress,
    :task_progress,
    :created_at,
    :updated_at,
    :workflows,
    :failed_blob,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :company,
    :template,
    :status,
    :completed,
    :workflow_progress,
    :task_progress,
    :workflows,
  ].freeze

  # Overwrite this method to customize how batches are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(batch)
    "Batch #{batch.name}"
  end
end
