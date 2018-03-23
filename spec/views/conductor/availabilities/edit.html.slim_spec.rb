require 'rails_helper'

RSpec.describe "availabilities/edit", type: :view do
  before(:each) do
    @availability = assign(:availability, Availability.create!(
      :user => nil,
      :assigned => false
    ))
  end

  it "renders the edit availability form" do
    render

    assert_select "form[action=?][method=?]", availability_path(@availability), "post" do

      assert_select "input#availability_user_id[name=?]", "availability[user_id]"

      assert_select "input#availability_assigned[name=?]", "availability[assigned]"
    end
  end
end
