FactoryBot.define do
  factory :document do
    remarks { Faker::Lorem.sentence }

    company
    document_template

    factory :document_with_workflow do
      workflow
    end
  end
end
