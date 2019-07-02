require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:company) }

  it { should belong_to(:company) }

  it { should have_many(:reminders) }
  it { should have_many(:clients) }
  it { should have_many(:documents) }
  it { should have_many(:recurring_workflows) }
  it { should have_many(:assigned_tasks) }
  it { should have_many(:completed_tasks) }
  it { should have_many(:availabilities) }
  it { should have_many(:allocations) }
  it { should have_many(:owned_events) }
  it { should have_many(:invoices) }
  it { should have_many(:batches) }

  it { should have_one(:profile) }
  it { should have_one(:address) }

  it { should accept_nested_attributes_for(:address) }
  it { should accept_nested_attributes_for(:company) }

  it { should define_enum_for(:bank_account_type) }
end