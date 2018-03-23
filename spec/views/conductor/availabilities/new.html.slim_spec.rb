require 'rails_helper'

RSpec.describe "availabilities/new", type: :view do
  before(:each) do
    assign(:availability, Availability.new(
      :user => nil,
      :assigned => false
    ))
  end

  it "renders new availability form" do
    render

    assert_select "form[action=?][method=?]", availabilities_path, "post" do

      assert_select "input#availability_user_id[name=?]", "availability[user_id]"

      assert_select "input#availability_assigned[name=?]", "availability[assigned]"
    end
  end
end
