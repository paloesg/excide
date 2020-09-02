FactoryBot.define do
  factory :template do
    title { Faker::Job.title }
    company

    factory :template_with_workflow do
      after(:create) do |t|
        create(:workflow_with_document, template: t, company: t.company)
      end
    end

    factory :template_with_sections do
      after(:create) do |t|
        create_list(:section, 3, template: t) do |section|
          create_list(:task, 3, section: section, role: create(:staffer).roles.first)
        end
      end
    end
  end
end
