require 'rails_helper'

RSpec.describe XeroContact, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:contact_id) }
  it { should validate_uniqueness_of(:contact_id) }
  it { should belong_to(:company) }
end
