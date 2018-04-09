FactoryBot.define do
  factory :section do
    unique_name Faker::Name.title
    display_name Faker::Name.title
    sequence(:position) { |n| n }
    template

    factory :section_with_task do
      after(:create) do |section|
        create_list(:task, 3, section: section)
      end
    end
  end
end