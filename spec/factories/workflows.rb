FactoryBot.define do
  factory :workflow do |workflow|
    workflow.identifier { Faker::Name.title}
    workflow.workflowable_type "Client"

    after(:create) do |workflow|
      create_list(:section, 3, template: workflow.template)
    end

    factory :workflow_with_document do
      transient do
        workflow.company
      end

      after(:create) do |w|
        create(:document_template, template: w.template) do |d|
          create(:document, workflow_id: w.id, company: w.company, document_template: d)
        end
      end
    end
  end
end