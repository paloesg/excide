require 'rails_helper'

RSpec.describe Enquiry, :type => :model do
	before(:all) do
		@enquiry1 = create(:enquiry)
	end
	
	it "is valid with valid attributes" do
    	expect(@enquiry1).to be_valid
    end

    it "is not valid without name" do
    	enquiry1 = build(:enquiry, name: nil)
    	expect(@enquiry1).to_not be_valid
    end

    it "is not valid without contact number" do
    	enquiry1 = build(:enquiry, contact: nil)
    	expect(@enquiry1).to_not be_valid
    end

    it "is not valid without email" do
    	enquiry1 = build(:enquiry, email: nil)
    	expect(@enquiry1).to_not be_valid
    end
end