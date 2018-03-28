FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password '12345678'
    password_confirmation '12345678'
    contact_number Faker::PhoneNumber.phone_number
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    company

    factory :admin_user do
      after(:create) { |user| user.add_role :admin }
    end

    factory :company_admin do
      after(:create) { |user| user.add_role :admin, user.company }
    end
  end
end