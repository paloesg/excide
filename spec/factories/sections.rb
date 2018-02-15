FactoryBot.define do
  factory :section, :class => "Section" do
    unique_name Faker::Name.title
    display_name Faker::Name.title
    position 1
  end
end