require "administrate/base_dashboard"

class ReminderDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    next_reminder: Field::DateTime,
    repeat: Field::Boolean,
    freq_value: Field::Number,
    freq_unit: EnumField,
    past_reminders: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    user: Field::BelongsTo,
    company: Field::BelongsTo,
    title: Field::String,
    content: Field::Text,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :company,
    :title,
    :next_reminder,
    :repeat,
    :freq_value,
    :freq_unit,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :title,
    :content,
    :next_reminder,
    :repeat,
    :freq_value,
    :freq_unit,
    :created_at,
    :updated_at,
    :user,
    :company,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :title,
    :content,
    :next_reminder,
    :repeat,
    :freq_value,
    :freq_unit,
    :company,
  ].freeze

  # Overwrite this method to customize how reminders are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(reminder)
  #   "Reminder ##{reminder.id}"
  # end
end
