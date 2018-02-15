FactoryBot.define do
  factory :workflow do
    identifier Faker::Name.title
    workflowable_type "Client"

    factory :workflow_with_document do
      transient do
        company
      end

      after(:create) do |w|
        create(:document, workflow_id: w.id, company: w.company)
      end
    end
  end
end