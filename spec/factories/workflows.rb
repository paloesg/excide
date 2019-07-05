FactoryBot.define do
  factory :workflow do |workflow|
    association :workflowable, factory: :client

    company
    template

    after(:create) do |workflow, evaluator|
      create_list(:section, 3, template: evaluator.template) do |section|
        create_list(:task, 3, section: section) do |task|
          create(:workflow_action, task: task, workflow: workflow, company: evaluator.company)
        end
      end
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