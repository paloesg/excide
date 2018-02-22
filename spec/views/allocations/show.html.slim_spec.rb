require 'rails_helper'

RSpec.describe "allocations/show", type: :view do
  before(:each) do
    @allocation = assign(:allocation, Allocation.create!(
      :user => nil,
      :activation => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
