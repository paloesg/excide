FactoryBot.define do
  factory :section, :class => "Section" do
    unique_name Faker::Name.title
    display_name Faker::Name.title
    sequence(:position) { |n| n }

    after(:create) do |section|
      create_list(:task, 3, section: section)
    end
  end
end