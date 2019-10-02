require 'rails_helper'

RSpec.describe Company, type: :model do
  it { should belong_to(:consultant) }
  it { should belong_to(:associate) }
  it { should belong_to(:shared_service) }

  it { should have_many(:users) }
  it { should have_many(:documents) }
  it { should have_many(:templates) }
  it { should have_many(:workflows) }
  it { should have_many(:recurring_workflows) }
  it { should have_many(:workflow_actions) }
  it { should have_many(:clients) }
  it { should have_many(:events) }
  it { should have_many(:reminders) }
  it { should have_many(:batches) }
  it { should have_one(:address) }

  it { should accept_nested_attributes_for(:address) }

  it { should define_enum_for(:company_type) }
  it { should define_enum_for(:gst_quarter) }
end