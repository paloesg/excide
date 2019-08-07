FactoryBot.define do
  factory :reminder do
    user
    company
    next_reminder { Time.zone.today }
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    slack { true }
    sms { true }

    trait :email do
      email { true }
    end
  end
end
