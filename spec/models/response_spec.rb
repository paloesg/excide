require 'rails_helper'

RSpec.describe Response, type: :model do
  it { should belong_to(:question) }
  it { should belong_to(:choice) }
  it { should belong_to(:segment) }
end