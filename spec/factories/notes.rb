FactoryBot.define do
  factory :note do
    notable_type { "MyString" }
    notable_id { "" }
    content { "MyText" }
    user { nil }
  end
end
