FactoryBot.define do
  factory :document, :class => "Document" do
    identifier Faker::Name.title
    file_url Faker::File.file_name('foo/bar', 'baz', 'jpg')
  end
end
