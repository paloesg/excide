FactoryBot.define do
  factory :template, :class => "Template" do
    title SecureRandom.hex
    slug SecureRandom.hex

    factory :template_with_workflow do
      transient do
        company
      end

      after(:create) do |t|
        create(:workflow, template: t, company: t.company)
      end
    end
  end
end