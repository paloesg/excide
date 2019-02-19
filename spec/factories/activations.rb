FactoryBot.define do
  factory :activation do
    company
    client
    event_owner

    activation_type { "happy_cart" }
    start_time { "2018-02-22 10:00:00" }
    end_time { "2018-02-22 12:00:00" }
    remarks { Faker::Lorem.sentence }
    location { Faker::Lorem.sentence }
  end
end
