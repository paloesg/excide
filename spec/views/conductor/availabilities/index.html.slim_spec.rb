require 'rails_helper'

RSpec.describe "availabilities/index", type: :view do
  before(:each) do
    assign(:availabilities, [
      Availability.create!(
        :user => nil,
        :assigned => false
      ),
      Availability.create!(
        :user => nil,
        :assigned => false
      )
    ])
  end

  it "renders a list of availabilities" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
