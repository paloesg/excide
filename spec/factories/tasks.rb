FactoryBot.define do
  factory :task do
    instructions Faker::Lorem.sentence
    position 1
    task_type 1
  end
end
