FactoryBot.define do
  factory :allocation do
    user
    event
    allocation_date { "2018-02-22" }
    start_time { "2018-02-22 23:26:28" }
    end_time { "2018-02-22 23:26:28" }
  end
end
