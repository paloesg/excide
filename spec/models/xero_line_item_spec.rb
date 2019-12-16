require 'rails_helper'

RSpec.describe XeroLineItem, type: :model do
  it { should belong_to(:company) }
end
