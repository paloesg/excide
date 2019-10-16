FactoryBot.define do
  factory :document do
    filename { Faker::File.file_name }
    remarks { Faker::Lorem.sentence }
    file_url { Faker::File.file_name(dir: 'foo/bar', name: 'baz', ext: 'pdf') }

    company
    document_template

    factory :document_with_workflow do
      workflow
    end
  end
end
