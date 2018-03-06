FactoryBot.define do
  factory :document, :class => "Document" do |document|
    document.identifier { Faker::Name.title }
    document.file_url { Faker::File.file_name('foo/bar', 'baz', 'jpg') }

    factory :document_with_company do
      company
    end
  end
end
