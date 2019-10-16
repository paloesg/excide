FactoryBot.define do
  factory :document_template do
    title { Faker::Job.title }
    file_url { Faker::File.file_name(dir: 'foo/bar', name: 'baz', ext: 'doc') }
    template
    user
  end
end
