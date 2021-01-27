FactoryBot.define do
  factory :topic do
    subject_name { "MyString" }
    status { 1 }
    question_category { 1 }
    user { nil }
    company { nil }
  end
end
