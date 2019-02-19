FactoryBot.define do
  factory :reminder do
    user
    company
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    slack { true }

    trait :email do
      email { true }
    end

    trait :sms do
      sms { true }
    end
  end
end
