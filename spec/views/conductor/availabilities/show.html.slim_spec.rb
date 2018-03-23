require 'rails_helper'

RSpec.describe "availabilities/show", type: :view do
  before(:each) do
    @availability = assign(:availability, Availability.create!(
      :user => nil,
      :assigned => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
  end
end
