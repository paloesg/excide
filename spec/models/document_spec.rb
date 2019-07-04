require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should validate_presence_of(:file_url) }
  it { should validate_presence_of(:filename) }

  it { should validate_uniqueness_of(:file_url) }

  it { should belong_to(:company) }
  it { should belong_to(:workflow) }
  it { should belong_to(:document_template) }
  it { should belong_to(:user) }
  it { should belong_to(:workflow_action) }

  it { should validate_uniqueness_of(:file_url) }
end
