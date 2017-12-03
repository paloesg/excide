require 'rails_helper'

RSpec.describe Task, type: :model do
  it { should validate_presence_of(:instructions) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:section) }
  it { should validate_presence_of(:role) }
  it { should validate_presence_of(:task_type) }

  it { should belong_to(:section) }
  it { should belong_to(:role) }
  it { should have_many(:reminders) }
  it { should have_many(:company_actions) }
end
