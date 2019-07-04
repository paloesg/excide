FactoryBot.define do
  factory :workflow do |workflow|
    association :workflowable, factory: :client

    company
    @template = template

    after(:create) do |workflow|
      create_list(:section, 3, template: @template)
    end

    factory :workflow_with_document do
      after(:create) do |w|
        create(:document_template, template: @template) do |d|
          create(:document, workflow_id: w.id, company: w.company, document_template: d)
        end
      end
    end
  end
end