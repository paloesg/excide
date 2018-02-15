FactoryBot.define do
  factory :template, :class => "Template" do
    title Faker::Name.title
    slug Faker::Internet.slug

    factory :template_with_workflow_and_document do
      transient do
        company
      end

      after(:create) do |t|
        create(:workflow_with_document, template: t, company: t.company)
      end
    end
  end
end
