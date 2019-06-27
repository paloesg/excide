require 'rails_helper'

RSpec.describe WorkflowAction, type: :model do
  it { should belong_to(:task) }
  it { should belong_to(:company) }
  it { should belong_to(:workflow) }
  it { should belong_to(:assigned_user) }
  it { should belong_to(:completed_user) }

  it { should have_many(:reminders) }
  it { should have_many(:documents) }

end