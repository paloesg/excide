FactoryBot.define do
  factory :event do
    company
    staffer

    start_time { 2.hours.ago }
    end_time { 1.hour.ago }
    remarks { Faker::Lorem.sentence }
    location { Faker::Lorem.sentence }
  end
end
