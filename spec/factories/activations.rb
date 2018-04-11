FactoryBot.define do
  factory :activation do
    user
    company
    client
    activation_type 'happy_cart'
    start_time "2018-02-22 23:26:28"
    end_time "2018-02-22 23:26:28"
    remarks Faker::Lorem.sentence
    location Faker::Lorem.sentence
  end
end
