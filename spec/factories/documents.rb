FactoryBot.define do
  factory :document, :class => "Document" do
    identifier "This is a new title"
    file_url "This is the body"
  end

  factory :document_with_template do
    transient do
      company
    end

    after(:create) do |d|
      create(:template_with_workflow, company: d.company)
    end
  end
end
