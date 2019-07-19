FactoryBot.define do
  factory :invoice do
    invoice_identifier { Faker::Internet.email }
    invoice_date { Time.zone.today }
    due_date { Time.zone.today.next_month }
    line_items { [] }
    line_amount_type { 0 }
    invoice_type { 0 }
    xero_invoice_id { 0 }
    xero_contact_id { 0 }
    xero_contact_name { "sansa" }
    currency { "USD" }
    approved { true }
    total { 123 }
    user
  end
end