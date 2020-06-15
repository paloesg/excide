require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:company) }
  it { should belong_to(:workflow) }
  it { should belong_to(:document_template) }
  it { should belong_to(:user) }
  it { should belong_to(:workflow_action) }
end
