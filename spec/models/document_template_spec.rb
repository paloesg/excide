require 'rails_helper'

RSpec.describe DocumentTemplate, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:file_url) }
  it { should validate_presence_of(:template) }

  it { should belong_to(:template) }
  it { should belong_to(:user) }
  it { should have_many(:documents) }
  it { should have_many(:tasks) }
end
