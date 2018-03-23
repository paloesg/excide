require 'rails_helper'

RSpec.describe "allocations/index", type: :view do
  before(:each) do
    assign(:allocations, [
      Allocation.create!(
        :user => nil,
        :activation => nil
      ),
      Allocation.create!(
        :user => nil,
        :activation => nil
      )
    ])
  end

  it "renders a list of allocations" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
