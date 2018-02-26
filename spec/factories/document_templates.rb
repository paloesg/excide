FactoryBot.define do
  factory :document_template do |document_template|
    document_template.title { Faker::Name.title }
    document_template.file_url { Faker::File.file_name('foo/bar', 'baz', 'jpg') }
  end
end