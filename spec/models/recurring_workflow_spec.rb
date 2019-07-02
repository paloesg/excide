require 'rails_helper'

RSpec.describe RecurringWorkflow, type: :model do
  it { should belong_to(:template) }
  it { should belong_to(:company) }
  it { should belong_to(:user) }

  it { should have_many(:workflows) }

  it { should define_enum_for(:freq_unit) }
end
