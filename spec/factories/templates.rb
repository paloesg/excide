FactoryBot.define do
  factory :template do
    title Faker::Name::title
    company

    factory :template_with_workflow do
      after(:create) do |t|
        create(:workflow_with_document, template: t, company: t.company)
      end
    end
  end
end
