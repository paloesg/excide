FactoryBot.define do
  factory :document, :class => "Document" do |document|
    document.identifier { Faker::Name.title }
    document.file_url { Faker::File.file_name('foo/bar', 'baz', 'jpg') }
  end
end
