FactoryBot.define do
  factory :document do
    filename Faker::File.file_name
    remarks Faker::Lorem.sentence
    file_url Faker::File.file_name('foo/bar', 'baz', 'doc')
    identifier Faker::Name.title

    company
    workflow
    document_template
  end
end
