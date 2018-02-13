FactoryBot.define do
  factory :workflow, :class => "Workflow" do
    identifier SecureRandom.hex
  end
end