require 'rails_helper'

RSpec.describe "conductor/allocations/edit", type: :view do
  before(:each) do
    @allocation = assign(:allocation, Allocation.create!(
      :user => nil,
      :activation => nil
    ))
  end

  it "renders the edit allocation form" do
    render

    assert_select "form[action=?][method=?]", conductor_allocation_path(@allocation), "post" do

      assert_select "input#allocation_user_id[name=?]", "allocation[user_id]"

      assert_select "input#allocation_activation_id[name=?]", "allocation[activation_id]"
    end
  end
end
