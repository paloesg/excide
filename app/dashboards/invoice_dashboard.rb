require "administrate/base_dashboard"

class InvoiceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::String.with_options(searchable: false),
    company: Field::BelongsTo,
    user: Field::BelongsTo,
    workflow: Field::BelongsTo,
    status: EnumField,
    remarks: Field::String,
    invoice_identifier: Field::String,
    invoice_reference: Field::String,
    invoice_date: Field::DateTime,
    invoice_type: EnumField,
    due_date: Field::DateTime,
    line_amount_type: EnumField,
    currency: Field::String,
    xero_invoice_id: Field::String,
    xero_contact_id: Field::String,
    xero_contact_name: Field::String,
    line_items: Field::JSONB,
    total: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :company,
    :invoice_date,
    :total,
    :status,
    :workflow,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :status,
    :remarks,
    :invoice_identifier,
    :invoice_reference,
    :invoice_date,
    :invoice_type,
    :due_date,
    :line_amount_type,
    :currency,
    :xero_invoice_id,
    :xero_contact_id,
    :xero_contact_name,
    :line_items,
    :total,
  ].freeze

  # Overwrite this method to customize how invoices are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(invoice)
    "Invoice ##{invoice.id}"
  end
end
