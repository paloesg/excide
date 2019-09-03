FactoryBot.define do
  factory :batch do
    company
    template { create(:template_with_sections) }
  end
end
