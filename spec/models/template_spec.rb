require 'rails_helper'

RSpec.describe Template, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:slug) }

  it { should belong_to(:company) }
  it { should have_many(:sections) }
  it { should have_many(:workflows) }
  it { should have_many(:recurring_workflows) }
  it { should have_many(:document_templates) }

  it { should accept_nested_attributes_for(:sections) }
  it { should define_enum_for(:business_model) }
  it { should define_enum_for(:workflow_type)}

  it 'is invalid with start date in the past' do
    template = Template.new(start_date: 2.days.ago)
    expect(template).to be_invalid
    expect(template.errors[:start_date]).not_to be_empty
  end
end
