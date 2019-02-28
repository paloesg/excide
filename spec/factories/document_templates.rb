FactoryBot.define do
  factory :document_template do
    title { Faker::Job.title }
    file_url { Faker::File.file_name('foo/bar', 'baz', 'doc') }
    template
    user
  end
end