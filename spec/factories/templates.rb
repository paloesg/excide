FactoryBot.define do
  factory :template, :class => "Template" do |template|
    template.title { Faker::Name::title }
    template.slug { Faker::Internet::slug }

    factory :template_with_workflow do
      transient do
        template.company
      end

      after(:create) do |t|
        create(:workflow_with_document, template: t, company: t.company)
      end
    end
  end
end
