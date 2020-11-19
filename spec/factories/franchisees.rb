FactoryBot.define do
  factory :franchisee do
    name { "MyString" }
    website { "MyString" }
    established_date { "2020-10-30" }
    telephone { "MyString" }
    annual_turnover_rate { "9.99" }
    currency { 1 }
    address { "MyString" }
    description { "MyText" }
    contact_person_details { "" }
  end
end
