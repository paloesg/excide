FactoryBot.define do
  factory :enquiry do
    name { Faker::Name.name }
    contact { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    comments { Faker::Lorem.paragraph }
    responded { false }

    factory :responded_enquiry do
      responded { true }
    end
  end
end
