require 'rails_helper'

RSpec.describe Workflow, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:company) }
  it { should belong_to(:template) }
  it { should belong_to(:recurring_workflow) }
  it { should belong_to(:batch) }
  it { should belong_to(:workflowable) }

  it { should have_many(:workflow_actions) }
  it { should have_many(:documents) }
end