FactoryBot.define do
  factory :section, :class => "Section" do
    unique_name SecureRandom.hex
    display_name SecureRandom.hex
    position 1
  end
end