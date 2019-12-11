FactoryBot.define do
  factory :xero_line_item do
    item_code { "MyString" }
    description { "MyString" }
    quantity { 1 }
    price { "9.99" }
    account { "MyString" }
    tax { "MyString" }
    company { nil }
  end
end
