require 'rails_helper'

RSpec.describe Task, type: :model do
  it { should validate_presence_of(:instructions) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:task_type) }

  it { should belong_to(:section) }
  it { should belong_to(:role) }
  it { should belong_to(:document_template) }
  it { should have_many(:reminders) }
  it { should have_many(:workflow_actions) }
end
