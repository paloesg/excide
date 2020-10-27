FactoryBot.define do
  factory :contact do
    name { "MyString" }
    phone { "MyString" }
    email { "MyString" }
    company_name { "MyString" }
    created_by { nil }
  end
end
