FactoryBot.define do
  factory :address do
    line_1 { Faker::Address.street_address }
    line_2 { Faker::Address.secondary_address }
    postal_code { Faker::Address.postcode }
    city { Faker::Address.city }
    country { Faker::Address.country }
    state { Faker::Address.state }
  end
end
