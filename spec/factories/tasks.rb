FactoryBot.define do
  factory :task do
    instructions Faker::Lorem.sentence
    task_type 'instructions'
    position 1
  end
end
