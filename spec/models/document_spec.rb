require 'rails_helper'

RSpec.describe Document, type: :model do
  subject { described_class.new(identifier: 'IDENTIFIER', file_url: 'https://excide.co/') }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without an identifier" do
    subject.identifier = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a file_url" do
    subject.file_url = nil
    expect(subject).to_not be_valid
  end
end
