require "administrate/base_dashboard"

class InvoiceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    workflow: Field::BelongsTo,
    id: Field::String.with_options(searchable: false),
    invoice_identifier: Field::String,
    invoice_date: Field::DateTime,
    due_date: Field::DateTime,
    line_items: Field::String.with_options(searchable: false),
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    line_amount_type: EnumField,
    invoice_type: EnumField
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :workflow,
    :id,
    :invoice_identifier,
    :invoice_date,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :workflow,
    :id,
    :invoice_identifier,
    :invoice_date,
    :due_date,
    :line_items,
    :created_at,
    :updated_at,
    :line_amount_type,
    :invoice_type,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :workflow,
    :invoice_identifier,
    :invoice_date,
    :due_date,
    :line_items,
    :line_amount_type,
    :invoice_type,
  ].freeze

  # Overwrite this method to customize how invoices are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(invoice)
    "Invoice ##{invoice.id}"
  end
end