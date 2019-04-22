FactoryBot.define do
  factory :recurring_workflow do
    recurring { false }
    freq_value { 1 }
    freq_unit { 1 }
    template { nil }
  end
end
