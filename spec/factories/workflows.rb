FactoryBot.define do
  factory :workflow do |workflow|
    association :workflowable, factory: :client

    workflow.identifier { Faker::Job.title}

    company

    after(:create) do |workflow|
      create_list(:section, 3, template: workflow.template)
    end

    factory :workflow_with_document do
      after(:create) do |w|
        create(:document_template, template: w.template) do |d|
          create(:document, workflow_id: w.id, company: w.company, document_template: d)
        end
      end
    end
  end
end