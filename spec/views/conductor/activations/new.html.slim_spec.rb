require 'rails_helper'

RSpec.describe "conductor/activations/new", type: :view do
  before(:each) do
    assign(:activation, Activation.new(
      :activation_type => 1,
      :remarks => "MyText",
      :location => "MyString",
      :start_time => Time.now,
      :end_time => Time.now + 1.day
    ))
  end

  it "renders new activation form" do
    render

    assert_select "form[action=?][method=?]", conductor_activations_path, "post" do

      assert_select "input#activation_activation_type[name=?]", "activation[activation_type]"

      assert_select "textarea#activation_remarks[name=?]", "activation[remarks]"

      assert_select "input#activation_location[name=?]", "activation[location]"
    end
  end
end
