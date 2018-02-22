require 'rails_helper'

RSpec.describe "allocations/new", type: :view do
  before(:each) do
    assign(:allocation, Allocation.new(
      :user => nil,
      :activation => nil
    ))
  end

  it "renders new allocation form" do
    render

    assert_select "form[action=?][method=?]", allocations_path, "post" do

      assert_select "input#allocation_user_id[name=?]", "allocation[user_id]"

      assert_select "input#allocation_activation_id[name=?]", "allocation[activation_id]"
    end
  end
end
