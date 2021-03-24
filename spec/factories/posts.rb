FactoryBot.define do
  factory :post do
    title { "MyString" }
    content { "MyText" }
    company { nil }
    user { nil }
  end
end
